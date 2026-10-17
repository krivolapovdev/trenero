package transaction

import (
	"context"
	"database/sql"
	"errors"
	"fmt"
	"strconv"
	"time"

	"github.com/google/uuid"
	"github.com/krivolapovdev/trenerio/internal/db"
	pkgerrors "github.com/krivolapovdev/trenerio/pkg/errors"
	"github.com/krivolapovdev/trenerio/pkg/logger"
	"github.com/krivolapovdev/trenerio/pkg/models"
	"github.com/krivolapovdev/trenerio/pkg/types"
	timeutil "github.com/krivolapovdev/trenerio/pkg/utils"
)

type FetchStudentsByIDsFunc func(ctx context.Context, studentIDs []uuid.UUID, ownerID uuid.UUID) ([]models.StudentResponse, error)
type FetchStudentByIDFunc func(ctx context.Context, studentID, ownerID uuid.UUID) (models.StudentResponse, error)

type Service interface {
	GetPaginatedTransactions(ctx context.Context, page, size int, ownerID uuid.UUID) (models.PageTransactionResponse, error)
	GetTransactionsBetween(ctx context.Context, startDate, endDate time.Time, ownerID uuid.UUID) ([]models.TransactionResponse, error)
	GetTransactionsByStudentID(ctx context.Context, studentID, ownerID uuid.UUID) ([]models.TransactionResponse, error)
	GetTransactionsByStudentIDs(ctx context.Context, studentIDs []uuid.UUID, ownerID uuid.UUID) (map[uuid.UUID][]models.TransactionResponse, error)
	CreateTransaction(ctx context.Context, req models.CreateTransactionRequest, ownerID uuid.UUID) (models.TransactionResponse, error)
	CreateStudentPayment(ctx context.Context, studentID uuid.UUID, amount float64, date, paidUntil time.Time, ownerID uuid.UUID) (models.TransactionResponse, error)
	UpdateTransaction(ctx context.Context, transactionID, ownerID uuid.UUID, updates map[string]any) (models.TransactionResponse, error)
	DeleteTransaction(ctx context.Context, transactionID, ownerID uuid.UUID) error
}

type service struct {
	db                 *db.Queries
	sqlDB              *sql.DB
	fetchStudentsByIDs FetchStudentsByIDsFunc
	fetchStudentByID   FetchStudentByIDFunc
}

func NewService(
	queries *db.Queries,
	sqlDB *sql.DB,
	fetchStudentsByIDs FetchStudentsByIDsFunc,
	fetchStudentByID FetchStudentByIDFunc,
) Service {
	return &service{
		db:                 queries,
		sqlDB:              sqlDB,
		fetchStudentsByIDs: fetchStudentsByIDs,
		fetchStudentByID:   fetchStudentByID,
	}
}

func (s *service) withTx(ctx context.Context, fn func(qtx *db.Queries) error) (err error) {
	tx, err := s.sqlDB.BeginTx(ctx, nil)
	if err != nil {
		return err
	}
	defer func() {
		if p := recover(); p != nil {
			_ = tx.Rollback()
			panic(p)
		} else if err != nil {
			_ = tx.Rollback()
		}
	}()
	qtx := s.db.WithTx(tx)
	if err = fn(qtx); err != nil {
		return err
	}
	return tx.Commit()
}

func (s *service) GetPaginatedTransactions(ctx context.Context, page, size int, ownerID uuid.UUID) (models.PageTransactionResponse, error) {
	logger.InfoContext(ctx, "Getting paginated transactions", "page", page, "size", size, "user_id", ownerID.String())
	if size < 1 {
		logger.WarnContext(ctx, "Invalid page size for transactions", "size", size, "user_id", ownerID.String())
		return models.PageTransactionResponse{}, pkgerrors.NewBadRequest(fmt.Sprintf("size must be at least 1, but was %d", size))
	}

	pageIndex := page - 1
	if pageIndex < 0 {
		pageIndex = 0
	}
	offset := int32(pageIndex * size)

	totalElements, err := s.db.CountTransactionsByOwnerID(ctx, ownerID)
	if err != nil {
		logger.ErrorContext(ctx, "Failed to count transactions", "error", err, "user_id", ownerID.String())
		return models.PageTransactionResponse{}, err
	}

	rows, err := s.db.FindTransactionsByOwnerIDPaginated(ctx, db.FindTransactionsByOwnerIDPaginatedParams{
		OwnerID: ownerID,
		Limit:   int32(size),
		Offset:  offset,
	})
	if err != nil {
		logger.ErrorContext(ctx, "Failed to fetch paginated transactions", "error", err, "offset", offset, "limit", size, "user_id", ownerID.String())
		return models.PageTransactionResponse{}, err
	}

	studentIDs := make([]uuid.UUID, 0, len(rows))
	seenStudentIDs := make(map[uuid.UUID]bool, len(rows))
	for _, r := range rows {
		if r.StudentID.Valid && !seenStudentIDs[r.StudentID.UUID] {
			seenStudentIDs[r.StudentID.UUID] = true
			studentIDs = append(studentIDs, r.StudentID.UUID)
		}
	}

	studentNames := make(map[uuid.UUID]string, len(studentIDs))
	if len(studentIDs) > 0 && s.fetchStudentsByIDs != nil {
		stRows, err := s.fetchStudentsByIDs(ctx, studentIDs, ownerID)
		if err != nil {
			logger.WarnContext(ctx, "Failed to fetch student names for transactions", "error", err, "user_id", ownerID.String())
		} else {
			for _, sr := range stRows {
				studentNames[sr.ID] = sr.FullName
			}
		}
	}

	transactions := make([]models.TransactionResponse, 0, len(rows))
	for _, r := range rows {
		var details *models.StudentPaymentDetailsResponse
		if r.StudentID.Valid && r.PaidUntil.Valid {
			var studentName *string
			if name, ok := studentNames[r.StudentID.UUID]; ok {
				studentName = &name
			}
			details = &models.StudentPaymentDetailsResponse{
				DetailsType: types.DetailsTypeStudent,
				StudentID:   r.StudentID.UUID,
				PaidUntil:   r.PaidUntil.Time,
				StudentName: studentName,
			}
		}

		amt, _ := strconv.ParseFloat(r.Amount, 64)
		transactions = append(transactions, models.TransactionResponse{
			ID:             r.ID,
			Amount:         amt,
			Date:           r.Date,
			Type:           types.TransactionType(r.Type),
			CreatedAt:      r.CreatedAt,
			PaymentDetails: details,
		})
	}

	totalPages := 0
	if size > 0 {
		totalPages = int((totalElements + int64(size) - 1) / int64(size))
	}

	numberOfElements := len(transactions)
	isFirst := pageIndex == 0
	isLast := pageIndex >= totalPages-1 || totalPages == 0

	sortObj := &models.SortObject{
		Empty:    false,
		Sorted:   true,
		Unsorted: false,
	}

	pageableObj := &models.PageableObject{
		Offset:     int64(offset),
		PageNumber: pageIndex,
		PageSize:   size,
		Paged:      true,
		Unpaged:    false,
		Sort:       sortObj,
	}

	logger.InfoContext(ctx, "Retrieved paginated transactions",
		"page", page,
		"size", size,
		"total_elements", totalElements,
		"returned_count", numberOfElements,
		"user_id", ownerID.String(),
	)

	return models.PageTransactionResponse{
		TotalPages:       totalPages,
		TotalElements:    totalElements,
		Size:             size,
		Content:          transactions,
		Number:           pageIndex,
		First:            isFirst,
		Last:             isLast,
		NumberOfElements: numberOfElements,
		Empty:            numberOfElements == 0,
		Sort:             sortObj,
		Pageable:         pageableObj,
	}, nil
}

func (s *service) GetTransactionsBetween(ctx context.Context, startDate, endDate time.Time, ownerID uuid.UUID) ([]models.TransactionResponse, error) {
	logger.InfoContext(ctx, "Getting transactions between dates", "start_date", startDate.Format(time.RFC3339), "end_date", endDate.Format(time.RFC3339), "user_id", ownerID.String())
	rows, err := s.db.FindTransactionsByOwnerIDAndDateBetween(ctx, db.FindTransactionsByOwnerIDAndDateBetweenParams{
		OwnerID: ownerID,
		Date:    startDate,
		Date_2:  endDate,
	})
	if err != nil {
		logger.ErrorContext(ctx, "Failed to get transactions between dates", "error", err, "user_id", ownerID.String())
		return nil, err
	}

	transactions := make([]models.TransactionResponse, 0, len(rows))
	for _, r := range rows {
		amt, _ := strconv.ParseFloat(r.Amount, 64)
		transactions = append(transactions, models.TransactionResponse{
			ID:        r.ID,
			Amount:    amt,
			Date:      r.Date,
			Type:      types.TransactionType(r.Type),
			CreatedAt: r.CreatedAt,
		})
	}
	logger.DebugContext(ctx, "Retrieved transactions between dates", "count", len(transactions), "user_id", ownerID.String())
	return transactions, nil
}

func (s *service) GetTransactionsByStudentID(ctx context.Context, studentID, ownerID uuid.UUID) ([]models.TransactionResponse, error) {
	logger.InfoContext(ctx, "Getting transactions by student id", "student_id", studentID.String(), "user_id", ownerID.String())
	rows, err := s.db.FindStudentPaymentsByStudentIDAndOwnerID(ctx, db.FindStudentPaymentsByStudentIDAndOwnerIDParams{
		StudentID: studentID,
		OwnerID:   ownerID,
	})
	if err != nil {
		logger.ErrorContext(ctx, "Failed to get transactions by student id", "student_id", studentID.String(), "error", err, "user_id", ownerID.String())
		return nil, err
	}

	transactions := make([]models.TransactionResponse, 0, len(rows))
	for _, r := range rows {
		amt, _ := strconv.ParseFloat(r.Amount, 64)
		transactions = append(transactions, models.TransactionResponse{
			ID:        r.ID,
			Amount:    amt,
			Date:      r.Date,
			Type:      types.TransactionType(r.Type),
			CreatedAt: r.CreatedAt,
			PaymentDetails: &models.StudentPaymentDetailsResponse{
				DetailsType: types.DetailsTypeStudent,
				StudentID:   r.StudentID,
				PaidUntil:   r.PaidUntil,
			},
		})
	}
	logger.DebugContext(ctx, "Retrieved transactions by student id", "student_id", studentID.String(), "count", len(transactions), "user_id", ownerID.String())
	return transactions, nil
}

func (s *service) GetTransactionsByStudentIDs(ctx context.Context, studentIDs []uuid.UUID, ownerID uuid.UUID) (map[uuid.UUID][]models.TransactionResponse, error) {
	logger.InfoContext(ctx, "Getting transactions by student ids", "count", len(studentIDs), "user_id", ownerID.String())
	if len(studentIDs) == 0 {
		logger.DebugContext(ctx, "No student IDs provided to get transactions", "user_id", ownerID.String())
		return map[uuid.UUID][]models.TransactionResponse{}, nil
	}

	rows, err := s.db.FindStudentPaymentsByStudentIDsAndOwnerID(ctx, db.FindStudentPaymentsByStudentIDsAndOwnerIDParams{
		OwnerID: ownerID,
		Column2: studentIDs,
	})
	if err != nil {
		logger.ErrorContext(ctx, "Failed to get transactions by student ids", "error", err, "user_id", ownerID.String())
		return nil, err
	}

	transactionsByStudent := make(map[uuid.UUID][]models.TransactionResponse, len(studentIDs))
	for _, sid := range studentIDs {
		transactionsByStudent[sid] = []models.TransactionResponse{}
	}
	for _, r := range rows {
		amt, _ := strconv.ParseFloat(r.Amount, 64)
		transactionsByStudent[r.StudentID] = append(transactionsByStudent[r.StudentID], models.TransactionResponse{
			ID:        r.ID,
			Amount:    amt,
			Date:      r.Date,
			Type:      types.TransactionType(r.Type),
			CreatedAt: r.CreatedAt,
			PaymentDetails: &models.StudentPaymentDetailsResponse{
				DetailsType: types.DetailsTypeStudent,
				StudentID:   r.StudentID,
				PaidUntil:   r.PaidUntil,
			},
		})
	}
	logger.DebugContext(ctx, "Retrieved transactions by student ids", "count", len(rows), "user_id", ownerID.String())
	return transactionsByStudent, nil
}

func (s *service) CreateTransaction(ctx context.Context, req models.CreateTransactionRequest, ownerID uuid.UUID) (models.TransactionResponse, error) {
	logger.InfoContext(ctx, "Creating transaction", "amount", req.Amount, "type", string(req.Type), "user_id", ownerID.String())
	if req.Amount <= 0 {
		logger.WarnContext(ctx, "Transaction amount must be greater than 0", "amount", req.Amount, "user_id", ownerID.String())
		return models.TransactionResponse{}, pkgerrors.NewBadRequest("amount must be greater than 0")
	}

	if req.PaymentDetails != nil {
		if req.PaymentDetails.StudentID == uuid.Nil {
			logger.WarnContext(ctx, "Student ID must not be nil for student payment", "user_id", ownerID.String())
			return models.TransactionResponse{}, pkgerrors.NewBadRequest("studentId must not be null for student payment")
		}

		if s.fetchStudentByID != nil {
			if _, err := s.fetchStudentByID(ctx, req.PaymentDetails.StudentID, ownerID); err != nil {
				logger.WarnContext(ctx, "Student not found for transaction payment details", "student_id", req.PaymentDetails.StudentID.String(), "error", err, "user_id", ownerID.String())
				return models.TransactionResponse{}, err
			}
		}

		if timeutil.IsPaidUntilBeforeDate(req.PaymentDetails.PaidUntil, req.Date) {
			logger.WarnContext(ctx, "paidUntil must not be before payment date", "paid_until", req.PaymentDetails.PaidUntil.Format(time.RFC3339), "date", req.Date.Format(time.RFC3339), "user_id", ownerID.String())
			return models.TransactionResponse{}, pkgerrors.NewBadRequest("paidUntil must not be before the payment date")
		}
	}

	var createdTx db.PaymentsModuleTransaction
	var details *models.StudentPaymentDetailsResponse

	err := s.withTx(ctx, func(qtx *db.Queries) error {
		amountStr := strconv.FormatFloat(req.Amount, 'f', 2, 64)
		var err error
		createdTx, err = qtx.CreateTransaction(ctx, db.CreateTransactionParams{
			OwnerID: ownerID,
			Type:    db.PaymentsModuleTransactionType(req.Type),
			Amount:  amountStr,
			Date:    req.Date,
		})
		if err != nil {
			logger.ErrorContext(ctx, "Failed to create transaction record", "error", err, "user_id", ownerID.String())
			return err
		}

		if req.PaymentDetails != nil {
			sp, err := qtx.CreateStudentPayment(ctx, db.CreateStudentPaymentParams{
				TransactionID: createdTx.ID,
				StudentID:     req.PaymentDetails.StudentID,
				PaidUntil:     req.PaymentDetails.PaidUntil,
			})
			if err != nil {
				logger.ErrorContext(ctx, "Failed to create student payment details record", "transaction_id", createdTx.ID.String(), "student_id", req.PaymentDetails.StudentID.String(), "error", err, "user_id", ownerID.String())
				return err
			}
			details = &models.StudentPaymentDetailsResponse{
				DetailsType: types.DetailsTypeStudent,
				StudentID:   sp.StudentID,
				PaidUntil:   sp.PaidUntil,
			}
		}
		return nil
	})
	if err != nil {
		logger.ErrorContext(ctx, "Failed to create transaction in database", "error", err, "user_id", ownerID.String())
		return models.TransactionResponse{}, err
	}

	amt, _ := strconv.ParseFloat(createdTx.Amount, 64)
	logger.InfoContext(ctx, "Transaction created successfully", "transaction_id", createdTx.ID.String(), "amount", amt, "type", string(createdTx.Type), "user_id", ownerID.String())
	return models.TransactionResponse{
		ID:             createdTx.ID,
		Amount:         amt,
		Date:           createdTx.Date,
		Type:           types.TransactionType(createdTx.Type),
		CreatedAt:      createdTx.CreatedAt,
		PaymentDetails: details,
	}, nil
}

func (s *service) CreateStudentPayment(ctx context.Context, studentID uuid.UUID, amount float64, date, paidUntil time.Time, ownerID uuid.UUID) (models.TransactionResponse, error) {
	logger.InfoContext(ctx, "Creating student payment transaction", "student_id", studentID.String(), "amount", amount, "user_id", ownerID.String())
	if s.fetchStudentByID != nil {
		if _, err := s.fetchStudentByID(ctx, studentID, ownerID); err != nil {
			logger.WarnContext(ctx, "Student not found for student payment", "student_id", studentID.String(), "error", err, "user_id", ownerID.String())
			return models.TransactionResponse{}, err
		}
	}

	if timeutil.IsPaidUntilBeforeDate(paidUntil, date) {
		logger.WarnContext(ctx, "paidUntil must not be before payment date", "student_id", studentID.String(), "paid_until", paidUntil.Format(time.RFC3339), "date", date.Format(time.RFC3339), "user_id", ownerID.String())
		return models.TransactionResponse{}, pkgerrors.NewBadRequest("paidUntil must not be before the payment date")
	}

	var createdTx db.PaymentsModuleTransaction
	var sp db.PaymentsModuleStudentPayment

	err := s.withTx(ctx, func(qtx *db.Queries) error {
		amountStr := strconv.FormatFloat(amount, 'f', 2, 64)
		var err error
		createdTx, err = qtx.CreateTransaction(ctx, db.CreateTransactionParams{
			OwnerID: ownerID,
			Type:    db.PaymentsModuleTransactionTypeINCOME,
			Amount:  amountStr,
			Date:    date,
		})
		if err != nil {
			logger.ErrorContext(ctx, "Failed to create transaction record for student payment", "student_id", studentID.String(), "error", err, "user_id", ownerID.String())
			return err
		}

		sp, err = qtx.CreateStudentPayment(ctx, db.CreateStudentPaymentParams{
			TransactionID: createdTx.ID,
			StudentID:     studentID,
			PaidUntil:     paidUntil,
		})
		if err != nil {
			logger.ErrorContext(ctx, "Failed to create student payment record", "student_id", studentID.String(), "error", err, "user_id", ownerID.String())
			return err
		}
		return nil
	})
	if err != nil {
		logger.ErrorContext(ctx, "Failed to create student payment transaction in database", "student_id", studentID.String(), "error", err, "user_id", ownerID.String())
		return models.TransactionResponse{}, err
	}

	amt, _ := strconv.ParseFloat(createdTx.Amount, 64)
	logger.InfoContext(ctx, "Student payment created successfully", "transaction_id", createdTx.ID.String(), "student_id", studentID.String(), "amount", amt, "user_id", ownerID.String())
	return models.TransactionResponse{
		ID:        createdTx.ID,
		Amount:    amt,
		Date:      createdTx.Date,
		Type:      types.TransactionType(createdTx.Type),
		CreatedAt: createdTx.CreatedAt,
		PaymentDetails: &models.StudentPaymentDetailsResponse{
			DetailsType: types.DetailsTypeStudent,
			StudentID:   sp.StudentID,
			PaidUntil:   sp.PaidUntil,
		},
	}, nil
}

func (s *service) UpdateTransaction(ctx context.Context, transactionID, ownerID uuid.UUID, updates map[string]any) (models.TransactionResponse, error) {
	logger.InfoContext(ctx, "Updating transaction", "transaction_id", transactionID.String(), "user_id", ownerID.String())
	var updatedTx db.PaymentsModuleTransaction
	var details *models.StudentPaymentDetailsResponse

	err := s.withTx(ctx, func(qtx *db.Queries) error {
		existing, err := qtx.FindTransactionByIDAndOwnerID(ctx, db.FindTransactionByIDAndOwnerIDParams{
			ID:      transactionID,
			OwnerID: ownerID,
		})
		if err != nil {
			if errors.Is(err, sql.ErrNoRows) {
				logger.WarnContext(ctx, "Transaction to update not found", "transaction_id", transactionID.String(), "user_id", ownerID.String())
				return pkgerrors.NewNotFound("Transaction", transactionID, ownerID)
			}
			logger.ErrorContext(ctx, "Failed to find transaction for update", "transaction_id", transactionID.String(), "error", err, "user_id", ownerID.String())
			return err
		}

		amountStr := existing.Amount
		if rawAmt, ok := updates["amount"]; ok && rawAmt != nil {
			switch v := rawAmt.(type) {
			case float64:
				amountStr = strconv.FormatFloat(v, 'f', 2, 64)
			case string:
				amountStr = v
			}
		}

		txDate := existing.Date
		patchesDate := false
		if rawDate, ok := updates["date"]; ok && rawDate != nil {
			d, err := parseTime(rawDate)
			if err == nil {
				txDate = d
				patchesDate = true
			}
		}

		paidUntilDate := existing.PaidUntil.Time
		patchesPaidUntil := false
		if rawPU, ok := updates["paidUntil"]; ok && rawPU != nil {
			d, err := parseTime(rawPU)
			if err == nil {
				paidUntilDate = d
				patchesPaidUntil = true
			}
		}

		if (patchesDate || patchesPaidUntil) && existing.StudentID.Valid {
			if timeutil.IsPaidUntilBeforeDate(paidUntilDate, txDate) {
				logger.WarnContext(ctx, "paidUntil must not be before payment date for transaction update", "transaction_id", transactionID.String(), "user_id", ownerID.String())
				return pkgerrors.NewBadRequest("paidUntil must not be before the payment date")
			}
		}

		updatedTx, err = qtx.UpdateTransaction(ctx, db.UpdateTransactionParams{
			ID:      transactionID,
			OwnerID: ownerID,
			Amount:  amountStr,
			Date:    txDate,
		})
		if err != nil {
			logger.ErrorContext(ctx, "Failed to update transaction record", "transaction_id", transactionID.String(), "error", err, "user_id", ownerID.String())
			return err
		}

		if patchesPaidUntil && existing.StudentID.Valid {
			sp, err := qtx.UpdateStudentPayment(ctx, db.UpdateStudentPaymentParams{
				TransactionID: transactionID,
				PaidUntil:     paidUntilDate,
			})
			if err != nil {
				logger.ErrorContext(ctx, "Failed to update student payment record", "transaction_id", transactionID.String(), "error", err, "user_id", ownerID.String())
				return err
			}
			details = &models.StudentPaymentDetailsResponse{
				DetailsType: types.DetailsTypeStudent,
				StudentID:   sp.StudentID,
				PaidUntil:   sp.PaidUntil,
			}
		} else if existing.StudentID.Valid {
			details = &models.StudentPaymentDetailsResponse{
				DetailsType: types.DetailsTypeStudent,
				StudentID:   existing.StudentID.UUID,
				PaidUntil:   existing.PaidUntil.Time,
			}
		}

		return nil
	})
	if err != nil {
		logger.ErrorContext(ctx, "Failed to update transaction in database", "transaction_id", transactionID.String(), "error", err, "user_id", ownerID.String())
		return models.TransactionResponse{}, err
	}

	amt, _ := strconv.ParseFloat(updatedTx.Amount, 64)
	logger.InfoContext(ctx, "Transaction updated successfully", "transaction_id", updatedTx.ID.String(), "amount", amt, "user_id", ownerID.String())
	return models.TransactionResponse{
		ID:             updatedTx.ID,
		Amount:         amt,
		Date:           updatedTx.Date,
		Type:           types.TransactionType(updatedTx.Type),
		CreatedAt:      updatedTx.CreatedAt,
		PaymentDetails: details,
	}, nil
}

func (s *service) DeleteTransaction(ctx context.Context, transactionID, ownerID uuid.UUID) error {
	logger.InfoContext(ctx, "Deleting transaction", "transaction_id", transactionID.String(), "user_id", ownerID.String())
	err := s.withTx(ctx, func(qtx *db.Queries) error {
		_, err := qtx.FindTransactionByIDAndOwnerID(ctx, db.FindTransactionByIDAndOwnerIDParams{
			ID:      transactionID,
			OwnerID: ownerID,
		})
		if err != nil {
			if errors.Is(err, sql.ErrNoRows) {
				logger.WarnContext(ctx, "Transaction to delete not found", "transaction_id", transactionID.String(), "user_id", ownerID.String())
				return pkgerrors.NewNotFound("Transaction", transactionID, ownerID)
			}
			logger.ErrorContext(ctx, "Failed to find transaction for deletion", "transaction_id", transactionID.String(), "error", err, "user_id", ownerID.String())
			return err
		}

		if err := qtx.DeleteStudentPaymentByTransactionID(ctx, transactionID); err != nil {
			logger.ErrorContext(ctx, "Failed to delete student payment linked to transaction", "transaction_id", transactionID.String(), "error", err, "user_id", ownerID.String())
			return err
		}

		if err := qtx.DeleteTransactionByIDAndOwnerID(ctx, db.DeleteTransactionByIDAndOwnerIDParams{
			ID:      transactionID,
			OwnerID: ownerID,
		}); err != nil {
			logger.ErrorContext(ctx, "Failed to delete transaction record", "transaction_id", transactionID.String(), "error", err, "user_id", ownerID.String())
			return err
		}

		return nil
	})
	if err != nil {
		logger.ErrorContext(ctx, "Failed to delete transaction from database", "transaction_id", transactionID.String(), "error", err, "user_id", ownerID.String())
		return err
	}
	logger.InfoContext(ctx, "Transaction deleted successfully", "transaction_id", transactionID.String(), "user_id", ownerID.String())
	return nil
}

func parseTime(raw any) (time.Time, error) {
	switch val := raw.(type) {
	case string:
		layouts := []string{
			time.RFC3339Nano,
			time.RFC3339,
			time.DateOnly,
			"2006-01-02 15:04:05",
		}
		for _, layout := range layouts {
			if t, err := time.Parse(layout, val); err == nil {
				return t, nil
			}
		}
		return time.Time{}, errors.New("cannot parse time")
	case time.Time:
		return val, nil
	default:
		return time.Time{}, errors.New("cannot parse time")
	}
}
