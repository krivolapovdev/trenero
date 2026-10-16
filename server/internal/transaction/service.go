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
)

type FetchStudentsByIDsFunc func(ctx context.Context, studentIDs []uuid.UUID, ownerID uuid.UUID) ([]models.StudentResponse, error)
type FetchStudentByIDFunc func(ctx context.Context, studentID, ownerID uuid.UUID) (models.StudentResponse, error)

type Service struct {
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
) *Service {
	return &Service{
		db:                 queries,
		sqlDB:              sqlDB,
		fetchStudentsByIDs: fetchStudentsByIDs,
		fetchStudentByID:   fetchStudentByID,
	}
}

func (s *Service) withTx(ctx context.Context, fn func(qtx *db.Queries) error) error {
	tx, err := s.sqlDB.BeginTx(ctx, nil)
	if err != nil {
		return err
	}
	qtx := s.db.WithTx(tx)
	if err := fn(qtx); err != nil {
		_ = tx.Rollback()
		return err
	}
	return tx.Commit()
}

func (s *Service) GetPaginatedTransactions(ctx context.Context, page, size int, ownerID uuid.UUID) (models.PageTransactionResponse, error) {
	logger.InfoContext(ctx, "Getting paginated transactions", "page", page, "size", size, "user_id", ownerID.String())
	if size < 1 {
		return models.PageTransactionResponse{}, &pkgerrors.BadRequestError{
			Message: fmt.Sprintf("size must be at least 1, but was %d", size),
		}
	}

	pageIndex := page - 1
	if pageIndex < 0 {
		pageIndex = 0
	}
	offset := int32(pageIndex * size)

	totalElements, err := s.db.CountTransactionsByOwnerID(ctx, ownerID)
	if err != nil {
		return models.PageTransactionResponse{}, err
	}

	rows, err := s.db.FindTransactionsByOwnerIDPaginated(ctx, db.FindTransactionsByOwnerIDPaginatedParams{
		OwnerID: ownerID,
		Limit:   int32(size),
		Offset:  offset,
	})
	if err != nil {
		return models.PageTransactionResponse{}, err
	}

	studentIDs := make([]uuid.UUID, 0, len(rows))
	seenStudentIDs := make(map[uuid.UUID]bool)
	for _, r := range rows {
		if r.StudentID.Valid && !seenStudentIDs[r.StudentID.UUID] {
			seenStudentIDs[r.StudentID.UUID] = true
			studentIDs = append(studentIDs, r.StudentID.UUID)
		}
	}

	studentNames := make(map[uuid.UUID]string)
	if len(studentIDs) > 0 {
		stRows, err := s.fetchStudentsByIDs(ctx, studentIDs, ownerID)
		if err == nil {
			for _, sr := range stRows {
				studentNames[sr.ID] = sr.FullName
			}
		}
	}

	content := make([]models.TransactionResponse, 0, len(rows))
	for _, r := range rows {
		var pd *models.StudentPaymentDetailsResponse
		if r.StudentID.Valid && r.PaidUntil.Valid {
			var sName *string
			if name, ok := studentNames[r.StudentID.UUID]; ok {
				sName = &name
			}
			pd = &models.StudentPaymentDetailsResponse{
				DetailsType: "STUDENT",
				StudentID:   r.StudentID.UUID,
				PaidUntil:   r.PaidUntil.Time,
				StudentName: sName,
			}
		}

		amt, _ := strconv.ParseFloat(r.Amount, 64)
		content = append(content, models.TransactionResponse{
			ID:             r.ID,
			Amount:         amt,
			Date:           r.Date,
			Type:           types.TransactionType(r.Type),
			CreatedAt:      r.CreatedAt,
			PaymentDetails: pd,
		})
	}

	totalPages := 0
	if size > 0 {
		totalPages = int((totalElements + int64(size) - 1) / int64(size))
	}
	if totalPages == 0 && totalElements == 0 {
		totalPages = 0
	}

	numberOfElements := len(content)
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

	return models.PageTransactionResponse{
		TotalPages:       totalPages,
		TotalElements:    totalElements,
		Size:             size,
		Content:          content,
		Number:           pageIndex,
		First:            isFirst,
		Last:             isLast,
		NumberOfElements: numberOfElements,
		Empty:            numberOfElements == 0,
		Sort:             sortObj,
		Pageable:         pageableObj,
	}, nil
}

func (s *Service) GetTransactionsBetween(ctx context.Context, startDate, endDate time.Time, ownerID uuid.UUID) ([]models.TransactionResponse, error) {
	logger.InfoContext(ctx, "Getting transactions between dates", "start_date", startDate.Format(time.RFC3339), "end_date", endDate.Format(time.RFC3339), "user_id", ownerID.String())
	rows, err := s.db.FindTransactionsByOwnerIDAndDateBetween(ctx, db.FindTransactionsByOwnerIDAndDateBetweenParams{
		OwnerID: ownerID,
		Date:    startDate,
		Date_2:  endDate,
	})
	if err != nil {
		return nil, err
	}

	res := make([]models.TransactionResponse, 0, len(rows))
	for _, r := range rows {
		amt, _ := strconv.ParseFloat(r.Amount, 64)
		res = append(res, models.TransactionResponse{
			ID:        r.ID,
			Amount:    amt,
			Date:      r.Date,
			Type:      types.TransactionType(r.Type),
			CreatedAt: r.CreatedAt,
		})
	}
	return res, nil
}

func (s *Service) GetTransactionsByStudentID(ctx context.Context, studentID, ownerID uuid.UUID) ([]models.TransactionResponse, error) {
	logger.InfoContext(ctx, "Getting transactions by student id", "student_id", studentID.String(), "user_id", ownerID.String())
	rows, err := s.db.FindStudentPaymentsByStudentIDAndOwnerID(ctx, db.FindStudentPaymentsByStudentIDAndOwnerIDParams{
		StudentID: studentID,
		OwnerID:   ownerID,
	})
	if err != nil {
		return nil, err
	}

	res := make([]models.TransactionResponse, 0, len(rows))
	for _, r := range rows {
		amt, _ := strconv.ParseFloat(r.Amount, 64)
		res = append(res, models.TransactionResponse{
			ID:        r.ID,
			Amount:    amt,
			Date:      r.Date,
			Type:      types.TransactionType(r.Type),
			CreatedAt: r.CreatedAt,
			PaymentDetails: &models.StudentPaymentDetailsResponse{
				DetailsType: "STUDENT",
				StudentID:   r.StudentID,
				PaidUntil:   r.PaidUntil,
			},
		})
	}
	return res, nil
}

func (s *Service) GetTransactionsByStudentIDs(ctx context.Context, studentIDs []uuid.UUID, ownerID uuid.UUID) (map[uuid.UUID][]models.TransactionResponse, error) {
	logger.InfoContext(ctx, "Getting transactions by student ids", "count", len(studentIDs), "user_id", ownerID.String())
	if len(studentIDs) == 0 {
		return map[uuid.UUID][]models.TransactionResponse{}, nil
	}

	rows, err := s.db.FindStudentPaymentsByStudentIDsAndOwnerID(ctx, db.FindStudentPaymentsByStudentIDsAndOwnerIDParams{
		OwnerID: ownerID,
		Column2: studentIDs,
	})
	if err != nil {
		return nil, err
	}

	res := make(map[uuid.UUID][]models.TransactionResponse)
	for _, sid := range studentIDs {
		res[sid] = []models.TransactionResponse{}
	}
	for _, r := range rows {
		amt, _ := strconv.ParseFloat(r.Amount, 64)
		res[r.StudentID] = append(res[r.StudentID], models.TransactionResponse{
			ID:        r.ID,
			Amount:    amt,
			Date:      r.Date,
			Type:      types.TransactionType(r.Type),
			CreatedAt: r.CreatedAt,
			PaymentDetails: &models.StudentPaymentDetailsResponse{
				DetailsType: "STUDENT",
				StudentID:   r.StudentID,
				PaidUntil:   r.PaidUntil,
			},
		})
	}
	return res, nil
}

func (s *Service) CreateTransaction(ctx context.Context, req models.CreateTransactionRequest, ownerID uuid.UUID) (models.TransactionResponse, error) {
	logger.InfoContext(ctx, "Creating transaction", "amount", req.Amount, "type", string(req.Type), "user_id", ownerID.String())
	if req.Amount <= 0 {
		return models.TransactionResponse{}, &pkgerrors.BadRequestError{
			Message: "amount must be greater than 0",
		}
	}

	if req.PaymentDetails != nil {
		if req.PaymentDetails.StudentID == uuid.Nil {
			return models.TransactionResponse{}, &pkgerrors.BadRequestError{
				Message: "studentId must not be null for student payment",
			}
		}

		if _, err := s.fetchStudentByID(ctx, req.PaymentDetails.StudentID, ownerID); err != nil {
			return models.TransactionResponse{}, err
		}

		if req.PaymentDetails.PaidUntil.Before(req.Date) {
			return models.TransactionResponse{}, &pkgerrors.BadRequestError{
				Message: "paidUntil must not be before the payment date",
			}
		}
	}

	var createdTx db.PaymentsModuleTransaction
	var sp db.PaymentsModuleStudentPayment
	var pd *models.StudentPaymentDetailsResponse

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
			return err
		}

		if req.PaymentDetails != nil {
			sp, err = qtx.CreateStudentPayment(ctx, db.CreateStudentPaymentParams{
				TransactionID: createdTx.ID,
				StudentID:     req.PaymentDetails.StudentID,
				PaidUntil:     req.PaymentDetails.PaidUntil,
			})
			if err != nil {
				return err
			}
			pd = &models.StudentPaymentDetailsResponse{
				DetailsType: "STUDENT",
				StudentID:   sp.StudentID,
				PaidUntil:   sp.PaidUntil,
			}
		}
		return nil
	})
	if err != nil {
		return models.TransactionResponse{}, err
	}

	amt, _ := strconv.ParseFloat(createdTx.Amount, 64)
	return models.TransactionResponse{
		ID:             createdTx.ID,
		Amount:         amt,
		Date:           createdTx.Date,
		Type:           types.TransactionType(createdTx.Type),
		CreatedAt:      createdTx.CreatedAt,
		PaymentDetails: pd,
	}, nil
}

func (s *Service) CreateStudentPayment(ctx context.Context, studentID uuid.UUID, amount float64, date, paidUntil time.Time, ownerID uuid.UUID) (models.TransactionResponse, error) {
	logger.InfoContext(ctx, "Creating student payment transaction", "student_id", studentID.String(), "user_id", ownerID.String())
	if _, err := s.fetchStudentByID(ctx, studentID, ownerID); err != nil {
		return models.TransactionResponse{}, err
	}

	if paidUntil.Before(date) {
		return models.TransactionResponse{}, &pkgerrors.BadRequestError{
			Message: "paidUntil must not be before the payment date",
		}
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
			return err
		}

		sp, err = qtx.CreateStudentPayment(ctx, db.CreateStudentPaymentParams{
			TransactionID: createdTx.ID,
			StudentID:     studentID,
			PaidUntil:     paidUntil,
		})
		return err
	})
	if err != nil {
		return models.TransactionResponse{}, err
	}

	amt, _ := strconv.ParseFloat(createdTx.Amount, 64)
	return models.TransactionResponse{
		ID:        createdTx.ID,
		Amount:    amt,
		Date:      createdTx.Date,
		Type:      types.TransactionType(createdTx.Type),
		CreatedAt: createdTx.CreatedAt,
		PaymentDetails: &models.StudentPaymentDetailsResponse{
			DetailsType: "STUDENT",
			StudentID:   sp.StudentID,
			PaidUntil:   sp.PaidUntil,
		},
	}, nil
}

func (s *Service) UpdateTransaction(ctx context.Context, transactionID, ownerID uuid.UUID, updates map[string]interface{}) (models.TransactionResponse, error) {
	logger.InfoContext(ctx, "Updating transaction", "transaction_id", transactionID.String(), "user_id", ownerID.String())
	var updatedTx db.PaymentsModuleTransaction
	var pd *models.StudentPaymentDetailsResponse

	err := s.withTx(ctx, func(qtx *db.Queries) error {
		existing, err := qtx.FindTransactionByIDAndOwnerID(ctx, db.FindTransactionByIDAndOwnerIDParams{
			ID:      transactionID,
			OwnerID: ownerID,
		})
		if err != nil {
			if errors.Is(err, sql.ErrNoRows) {
				return &pkgerrors.NotFoundError{
					Entity:  "Transaction",
					ID:      transactionID,
					OwnerID: ownerID,
				}
			}
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
			if paidUntilDate.Before(txDate) {
				return &pkgerrors.BadRequestError{
					Message: "paidUntil must not be before the payment date",
				}
			}
		}

		updatedTx, err = qtx.UpdateTransaction(ctx, db.UpdateTransactionParams{
			ID:      transactionID,
			OwnerID: ownerID,
			Amount:  amountStr,
			Date:    txDate,
		})
		if err != nil {
			return err
		}

		if patchesPaidUntil && existing.StudentID.Valid {
			sp, err := qtx.UpdateStudentPayment(ctx, db.UpdateStudentPaymentParams{
				TransactionID: transactionID,
				PaidUntil:     paidUntilDate,
			})
			if err != nil {
				return err
			}
			pd = &models.StudentPaymentDetailsResponse{
				DetailsType: "STUDENT",
				StudentID:   sp.StudentID,
				PaidUntil:   sp.PaidUntil,
			}
		} else if existing.StudentID.Valid {
			pd = &models.StudentPaymentDetailsResponse{
				DetailsType: "STUDENT",
				StudentID:   existing.StudentID.UUID,
				PaidUntil:   existing.PaidUntil.Time,
			}
		}

		return nil
	})
	if err != nil {
		return models.TransactionResponse{}, err
	}

	amt, _ := strconv.ParseFloat(updatedTx.Amount, 64)
	return models.TransactionResponse{
		ID:             updatedTx.ID,
		Amount:         amt,
		Date:           updatedTx.Date,
		Type:           types.TransactionType(updatedTx.Type),
		CreatedAt:      updatedTx.CreatedAt,
		PaymentDetails: pd,
	}, nil
}

func (s *Service) DeleteTransaction(ctx context.Context, transactionID, ownerID uuid.UUID) error {
	logger.InfoContext(ctx, "Deleting transaction", "transaction_id", transactionID.String(), "user_id", ownerID.String())
	return s.withTx(ctx, func(qtx *db.Queries) error {
		_, err := qtx.FindTransactionByIDAndOwnerID(ctx, db.FindTransactionByIDAndOwnerIDParams{
			ID:      transactionID,
			OwnerID: ownerID,
		})
		if err != nil {
			if errors.Is(err, sql.ErrNoRows) {
				return &pkgerrors.NotFoundError{
					Entity:  "Transaction",
					ID:      transactionID,
					OwnerID: ownerID,
				}
			}
			return err
		}

		if err := qtx.DeleteStudentPaymentByTransactionID(ctx, transactionID); err != nil {
			return err
		}

		return qtx.DeleteTransactionByIDAndOwnerID(ctx, db.DeleteTransactionByIDAndOwnerIDParams{
			ID:      transactionID,
			OwnerID: ownerID,
		})
	})
}

func parseTime(v interface{}) (time.Time, error) {
	switch val := v.(type) {
	case string:
		return time.Parse(time.RFC3339, val)
	case time.Time:
		return val, nil
	default:
		return time.Time{}, errors.New("cannot parse time")
	}
}
