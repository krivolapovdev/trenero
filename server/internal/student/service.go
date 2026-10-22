package student

import (
	"context"
	"database/sql"
	"errors"
	"fmt"
	"sort"
	"time"

	"github.com/google/uuid"
	"github.com/krivolapovdev/trenerio/internal/db"
	pkgerrors "github.com/krivolapovdev/trenerio/internal/shared/errors"
	"github.com/krivolapovdev/trenerio/internal/shared/logger"
	"github.com/krivolapovdev/trenerio/internal/shared/request"
	"github.com/krivolapovdev/trenerio/internal/shared/response"
	"github.com/krivolapovdev/trenerio/internal/shared/types"
	"github.com/krivolapovdev/trenerio/internal/shared/validator"
	"github.com/krivolapovdev/trenerio/internal/transaction"
	"github.com/krivolapovdev/trenerio/internal/visit"
	"golang.org/x/sync/errgroup"
)

type VisitProvider interface {
	GetVisitsByStudentIDs(ctx context.Context, studentIDs []uuid.UUID, ownerID uuid.UUID) (map[uuid.UUID][]visit.VisitResponse, error)
	GetVisitsByStudentID(ctx context.Context, studentID, ownerID uuid.UUID) ([]visit.VisitResponse, error)
}

type TransactionProvider interface {
	GetTransactionsByStudentIDs(ctx context.Context, studentIDs []uuid.UUID, ownerID uuid.UUID) (map[uuid.UUID][]transaction.TransactionResponse, error)
	GetTransactionsByStudentID(ctx context.Context, studentID, ownerID uuid.UUID) ([]transaction.TransactionResponse, error)
	CreateStudentPayment(ctx context.Context, studentID uuid.UUID, amount float64, date, paidUntil time.Time, ownerID uuid.UUID) (transaction.TransactionResponse, error)
}

type GroupProvider interface {
	GetGroupsByStudentIDs(ctx context.Context, studentIDs []uuid.UUID, ownerID uuid.UUID) (map[uuid.UUID][]response.GroupResponse, error)
	SetStudentGroups(ctx context.Context, studentID, ownerID uuid.UUID, groupIDs []uuid.UUID) error
}

type LessonProvider interface {
	GetLessonsByIDs(ctx context.Context, lessonIDs []uuid.UUID, ownerID uuid.UUID) ([]response.LessonResponse, error)
}

type Service struct {
	db                  *db.Queries
	sqlDB               *sql.DB
	visitProvider       VisitProvider
	transactionProvider TransactionProvider
	groupProvider       GroupProvider
	lessonProvider      LessonProvider
}

func NewService(queries *db.Queries, sqlDB *sql.DB) *Service {
	return &Service{
		db:    queries,
		sqlDB: sqlDB,
	}
}

func (s *Service) SetDependencies(
	visitProvider VisitProvider,
	transactionProvider TransactionProvider,
	groupProvider GroupProvider,
	lessonProvider LessonProvider,
) {
	s.visitProvider = visitProvider
	s.transactionProvider = transactionProvider
	s.groupProvider = groupProvider
	s.lessonProvider = lessonProvider
}

func NewServiceWithDependencies(
	queries *db.Queries,
	sqlDB *sql.DB,
	visitProvider VisitProvider,
	transactionProvider TransactionProvider,
	groupProvider GroupProvider,
	lessonProvider LessonProvider,
) *Service {
	s := NewService(queries, sqlDB)
	s.SetDependencies(
		visitProvider,
		transactionProvider,
		groupProvider,
		lessonProvider,
	)
	return s
}

func (s *Service) withTx(ctx context.Context, fn func(qtx *db.Queries) error) error {
	if s.sqlDB == nil {
		return fn(s.db)
	}
	return db.WithTx(ctx, s.sqlDB, s.db, fn)
}

func (s *Service) GetAllStudents(ctx context.Context, ownerID uuid.UUID) ([]response.StudentResponse, error) {
	logger.InfoContext(ctx, "Getting all students", "user_id", ownerID.String())
	rows, err := s.db.FindAllStudentsByOwnerID(ctx, ownerID)
	if err != nil {
		logger.ErrorContext(ctx, "Failed to get all students", "error", err, "user_id", ownerID.String())
		return nil, err
	}
	students := make([]response.StudentResponse, 0, len(rows))
	for _, r := range rows {
		students = append(students, toStudentResponse(r))
	}
	logger.DebugContext(ctx, "Retrieved all students", "count", len(students), "user_id", ownerID.String())
	return students, nil
}

func (s *Service) GetStudentsByIDs(ctx context.Context, studentIDs []uuid.UUID, ownerID uuid.UUID) ([]response.StudentResponse, error) {
	if len(studentIDs) == 0 {
		logger.DebugContext(ctx, "No student IDs provided to get students", "user_id", ownerID.String())
		return []response.StudentResponse{}, nil
	}
	rows, err := s.db.FindStudentsByIDsAndOwnerID(ctx, db.FindStudentsByIDsAndOwnerIDParams{
		OwnerID: ownerID,
		Column2: studentIDs,
	})
	if err != nil {
		logger.ErrorContext(ctx, "Failed to get students by IDs", "count", len(studentIDs), "error", err, "user_id", ownerID.String())
		return nil, err
	}
	students := make([]response.StudentResponse, 0, len(rows))
	for _, r := range rows {
		students = append(students, toStudentResponse(r))
	}
	logger.DebugContext(ctx, "Retrieved students by IDs", "count", len(students), "user_id", ownerID.String())
	return students, nil
}

func (s *Service) GetTransactionStudentsByIDs(ctx context.Context, studentIDs []uuid.UUID, ownerID uuid.UUID) ([]transaction.StudentSummaryInfo, error) {
	students, err := s.GetStudentsByIDs(ctx, studentIDs, ownerID)
	if err != nil {
		return nil, err
	}
	res := make([]transaction.StudentSummaryInfo, len(students))
	for i, st := range students {
		res[i] = transaction.StudentSummaryInfo{ID: st.ID, FullName: st.FullName}
	}
	return res, nil
}

func (s *Service) GetAllStudentsSummary(ctx context.Context, ownerID uuid.UUID) ([]StudentSummaryResponse, error) {
	logger.InfoContext(ctx, "Getting students overview", "user_id", ownerID.String())
	students, err := s.GetAllStudents(ctx, ownerID)
	if err != nil {
		logger.ErrorContext(ctx, "Failed to get students for overview", "error", err, "user_id", ownerID.String())
		return nil, err
	}
	if len(students) == 0 {
		logger.InfoContext(ctx, "No students found for overview", "user_id", ownerID.String())
		return []StudentSummaryResponse{}, nil
	}

	studentIDs := make([]uuid.UUID, 0, len(students))
	for _, st := range students {
		studentIDs = append(studentIDs, st.ID)
	}

	var (
		visitsMap        map[uuid.UUID][]visit.VisitResponse
		paymentsMap      map[uuid.UUID][]transaction.TransactionResponse
		studentGroupsMap map[uuid.UUID][]response.GroupResponse
	)

	g, gCtx := errgroup.WithContext(ctx)
	if s.visitProvider != nil {
		g.Go(func() error {
			vm, err := s.visitProvider.GetVisitsByStudentIDs(gCtx, studentIDs, ownerID)
			if err != nil {
				return err
			}
			visitsMap = vm
			return nil
		})
	}
	if s.transactionProvider != nil {
		g.Go(func() error {
			pm, err := s.transactionProvider.GetTransactionsByStudentIDs(gCtx, studentIDs, ownerID)
			if err != nil {
				return err
			}
			paymentsMap = pm
			return nil
		})
	}
	if s.groupProvider != nil {
		g.Go(func() error {
			gm, err := s.groupProvider.GetGroupsByStudentIDs(gCtx, studentIDs, ownerID)
			if err != nil {
				return err
			}
			studentGroupsMap = gm
			return nil
		})
	}

	if err := g.Wait(); err != nil {
		logger.ErrorContext(ctx, "Failed to fetch student overview dependencies", "error", err, "user_id", ownerID.String())
		return nil, err
	}

	lessonIDsMap := make(map[uuid.UUID]bool)
	for _, vs := range visitsMap {
		for _, v := range vs {
			lessonIDsMap[v.LessonID] = true
		}
	}

	allLessonIDs := make([]uuid.UUID, 0, len(lessonIDsMap))
	for lid := range lessonIDsMap {
		allLessonIDs = append(allLessonIDs, lid)
	}

	lessonsMap := make(map[uuid.UUID]response.LessonResponse, len(allLessonIDs))
	if len(allLessonIDs) > 0 && s.lessonProvider != nil {
		lRows, err := s.lessonProvider.GetLessonsByIDs(ctx, allLessonIDs, ownerID)
		if err != nil {
			logger.ErrorContext(ctx, "Failed to fetch lessons for students overview", "error", err, "user_id", ownerID.String())
			return nil, err
		}
		for _, lr := range lRows {
			lessonsMap[lr.ID] = lr
		}
	}

	logger.DebugContext(ctx, "Computing student statuses for overview",
		"students_count", len(students),
		"lessons_count", len(lessonsMap),
		"user_id", ownerID.String(),
	)

	today := time.Now().UTC()
	summaries := make([]StudentSummaryResponse, 0, len(students))
	for _, st := range students {
		stVisits := visitsMap[st.ID]
		stPayments := paymentsMap[st.ID]

		statuses := ComputeStudentStatuses(st, stVisits, stPayments, lessonsMap, today)
		stGroups := studentGroupsMap[st.ID]
		if stGroups == nil {
			stGroups = []response.GroupResponse{}
		}

		summaries = append(summaries, StudentSummaryResponse{
			ID:            st.ID,
			FullName:      st.FullName,
			Birthdate:     st.Birthdate,
			Phone:         st.Phone,
			Note:          st.Note,
			CreatedAt:     st.CreatedAt,
			Free:          st.Free,
			Statuses:      statuses,
			StudentGroups: stGroups,
		})
	}

	logger.InfoContext(ctx, "Students overview generated successfully", "count", len(summaries), "user_id", ownerID.String())
	return summaries, nil
}

func (s *Service) GetStudentDetailsByID(ctx context.Context, studentID, ownerID uuid.UUID) (response.StudentResponse, error) {
	logger.InfoContext(ctx, "Getting student by id", "student_id", studentID.String(), "user_id", ownerID.String())
	st, err := s.db.FindStudentByIDAndOwnerID(ctx, db.FindStudentByIDAndOwnerIDParams{
		ID:      studentID,
		OwnerID: ownerID,
	})
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			logger.WarnContext(ctx, "Student not found", "student_id", studentID.String(), "user_id", ownerID.String())
			return response.StudentResponse{}, pkgerrors.NewNotFound("Student", studentID, ownerID)
		}
		logger.ErrorContext(ctx, "Failed to get student by id", "student_id", studentID.String(), "error", err, "user_id", ownerID.String())
		return response.StudentResponse{}, err
	}
	logger.DebugContext(ctx, "Retrieved student by id", "student_id", studentID.String(), "user_id", ownerID.String())
	return toStudentResponse(st), nil
}

func (s *Service) ValidateStudentExistsByID(ctx context.Context, studentID, ownerID uuid.UUID) error {
	_, err := s.GetStudentDetailsByID(ctx, studentID, ownerID)
	return err
}

func (s *Service) GetStudentVisits(ctx context.Context, studentID, ownerID uuid.UUID, from, to *time.Time) ([]response.VisitWithLessonResponse, error) {
	logger.InfoContext(ctx, "Getting student visits", "student_id", studentID.String(), "user_id", ownerID.String())
	if _, err := s.GetStudentDetailsByID(ctx, studentID, ownerID); err != nil {
		logger.WarnContext(ctx, "Student not found for visits", "student_id", studentID.String(), "error", err, "user_id", ownerID.String())
		return nil, err
	}

	var vRows []visit.VisitResponse
	if s.visitProvider != nil {
		var err error
		vRows, err = s.visitProvider.GetVisitsByStudentID(ctx, studentID, ownerID)
		if err != nil {
			logger.ErrorContext(ctx, "Failed to fetch student visits", "student_id", studentID.String(), "error", err, "user_id", ownerID.String())
			return nil, err
		}
	}
	if len(vRows) == 0 {
		return []response.VisitWithLessonResponse{}, nil
	}

	lessonIDs := make([]uuid.UUID, 0, len(vRows))
	for _, vr := range vRows {
		lessonIDs = append(lessonIDs, vr.LessonID)
	}

	lessonsMap := make(map[uuid.UUID]response.LessonResponse, len(lessonIDs))
	if len(lessonIDs) > 0 && s.lessonProvider != nil {
		lRows, err := s.lessonProvider.GetLessonsByIDs(ctx, lessonIDs, ownerID)
		if err != nil {
			logger.ErrorContext(ctx, "Failed to fetch lessons for student visits", "student_id", studentID.String(), "error", err, "user_id", ownerID.String())
			return nil, err
		}
		for _, lr := range lRows {
			lessonsMap[lr.ID] = lr
		}
	}

	visitsWithLessons := make([]response.VisitWithLessonResponse, 0, len(vRows))
	for _, vr := range vRows {
		lResp, ok := lessonsMap[vr.LessonID]
		if !ok {
			continue
		}
		if from != nil && lResp.Date.Before(*from) {
			continue
		}
		if to != nil && lResp.Date.After(*to) {
			continue
		}
		visitsWithLessons = append(visitsWithLessons, response.VisitWithLessonResponse{
			Visit:  vr,
			Lesson: lResp,
		})
	}

	sort.Slice(visitsWithLessons, func(i, j int) bool {
		return visitsWithLessons[i].Lesson.Date.After(visitsWithLessons[j].Lesson.Date)
	})

	logger.InfoContext(ctx, "Retrieved student visits",
		"student_id", studentID.String(),
		"total_visits", len(vRows),
		"filtered_visits", len(visitsWithLessons),
		"user_id", ownerID.String(),
	)
	return visitsWithLessons, nil
}

func (s *Service) GetStudentPayments(ctx context.Context, studentID, ownerID uuid.UUID) ([]transaction.TransactionResponse, error) {
	logger.InfoContext(ctx, "Getting payments for student", "student_id", studentID.String(), "user_id", ownerID.String())
	if _, err := s.GetStudentDetailsByID(ctx, studentID, ownerID); err != nil {
		logger.WarnContext(ctx, "Student not found for payments", "student_id", studentID.String(), "error", err, "user_id", ownerID.String())
		return nil, err
	}

	var payments []transaction.TransactionResponse
	if s.transactionProvider != nil {
		var err error
		payments, err = s.transactionProvider.GetTransactionsByStudentID(ctx, studentID, ownerID)
		if err != nil {
			logger.ErrorContext(ctx, "Failed to fetch student payments", "student_id", studentID.String(), "error", err, "user_id", ownerID.String())
			return nil, err
		}
	}
	logger.InfoContext(ctx, "Retrieved student payments", "student_id", studentID.String(), "count", len(payments), "user_id", ownerID.String())
	return payments, nil
}

func (s *Service) CreateStudent(ctx context.Context, req request.CreateStudentRequest, ownerID uuid.UUID) (response.StudentResponse, error) {
	logger.InfoContext(ctx, "Creating student", "name", req.FullName, "user_id", ownerID.String())
	fullName, err := validator.ValidateRequiredName(req.FullName, "fullName")
	if err != nil {
		logger.WarnContext(ctx, "Student full name validation failed", "user_id", ownerID.String())
		return response.StudentResponse{}, err
	}

	var birthdate sql.NullTime
	if req.Birthdate != nil {
		if err := validator.ValidateDateNotFuture(req.Birthdate.Time, "birthdate"); err != nil {
			logger.WarnContext(ctx, "Student birthdate cannot be in the future", "birthdate", req.Birthdate.Format(time.DateOnly), "user_id", ownerID.String())
			return response.StudentResponse{}, err
		}
		birthdate = sql.NullTime{Time: req.Birthdate.Time, Valid: true}
	}

	taken, err := s.db.ExistsStudentByOwnerIDAndFullName(ctx, db.ExistsStudentByOwnerIDAndFullNameParams{
		OwnerID:  ownerID,
		FullName: fullName,
	})
	if err != nil {
		logger.ErrorContext(ctx, "Failed to check student name uniqueness", "name", fullName, "error", err, "user_id", ownerID.String())
		return response.StudentResponse{}, err
	}
	if taken {
		logger.WarnContext(ctx, "Student with name already exists", "name", fullName, "user_id", ownerID.String())
		return response.StudentResponse{}, pkgerrors.NewConflict(
			ErrNameNotUnique,
			fmt.Sprintf("A student named \"%s\" already exists", fullName),
		)
	}
	var phone sql.NullString
	if req.Phone != nil && *req.Phone != "" {
		phone = sql.NullString{String: *req.Phone, Valid: true}
	}
	var note sql.NullString
	if req.Note != nil && *req.Note != "" {
		note = sql.NullString{String: *req.Note, Valid: true}
	}

	created, err := s.db.CreateStudent(ctx, db.CreateStudentParams{
		OwnerID:   ownerID,
		FullName:  fullName,
		Birthdate: birthdate,
		Phone:     phone,
		Note:      note,
		Free:      req.Free,
	})
	if err != nil {
		logger.ErrorContext(ctx, "Failed to create student record in database", "name", fullName, "error", err, "user_id", ownerID.String())
		return response.StudentResponse{}, err
	}

	logger.InfoContext(ctx, "Student created successfully", "student_id", created.ID.String(), "name", created.FullName, "user_id", ownerID.String())
	return toStudentResponse(created), nil
}

func (s *Service) CreateStudentPayment(ctx context.Context, studentID, ownerID uuid.UUID, req request.CreateStudentPaymentRequest) (transaction.TransactionResponse, error) {
	logger.InfoContext(ctx, "Creating payment for student", "student_id", studentID.String(), "amount", req.Amount, "user_id", ownerID.String())
	if err := validator.ValidateDateNotFuture(req.Date, "date"); err != nil {
		logger.WarnContext(ctx, "Student payment date cannot be in the future", "date", req.Date.Format(time.RFC3339), "user_id", ownerID.String())
		return transaction.TransactionResponse{}, err
	}

	if _, err := s.GetStudentDetailsByID(ctx, studentID, ownerID); err != nil {
		logger.WarnContext(ctx, "Student not found for creating payment", "student_id", studentID.String(), "error", err, "user_id", ownerID.String())
		return transaction.TransactionResponse{}, err
	}

	var payment transaction.TransactionResponse
	if s.transactionProvider != nil {
		var err error
		payment, err = s.transactionProvider.CreateStudentPayment(ctx, studentID, req.Amount, req.Date, req.PaidUntil, ownerID)
		if err != nil {
			logger.ErrorContext(ctx, "Failed to create payment for student", "student_id", studentID.String(), "error", err, "user_id", ownerID.String())
			return transaction.TransactionResponse{}, err
		}
	}

	logger.InfoContext(ctx, "Student payment created successfully", "student_id", studentID.String(), "transaction_id", payment.ID.String(), "user_id", ownerID.String())
	return payment, nil
}

func (s *Service) UpdateStudent(ctx context.Context, studentID, ownerID uuid.UUID, updates map[string]any) (response.StudentResponse, error) {
	logger.InfoContext(ctx, "Updating student", "student_id", studentID.String(), "user_id", ownerID.String())
	var updated db.StudentsModuleStudent

	err := s.withTx(ctx, func(qtx *db.Queries) error {
		existing, err := qtx.FindStudentByIDAndOwnerID(ctx, db.FindStudentByIDAndOwnerIDParams{
			ID:      studentID,
			OwnerID: ownerID,
		})
		if err != nil {
			if errors.Is(err, sql.ErrNoRows) {
				logger.WarnContext(ctx, "Student to update not found", "student_id", studentID.String(), "user_id", ownerID.String())
				return pkgerrors.NewNotFound("Student", studentID, ownerID)
			}
			logger.ErrorContext(ctx, "Failed to find student for update", "student_id", studentID.String(), "error", err, "user_id", ownerID.String())
			return err
		}

		fullName := existing.FullName
		if rawName, ok := updates["fullName"]; ok && rawName != nil {
			nameStr, isStr := rawName.(string)
			if !isStr {
				logger.WarnContext(ctx, "Updated student name must not be blank", "student_id", studentID.String(), "user_id", ownerID.String())
				return pkgerrors.NewBadRequest("fullName must not be blank")
			}
			trimmed, err := validator.ValidateRequiredName(nameStr, "fullName")
			if err != nil {
				logger.WarnContext(ctx, "Updated student name validation failed", "student_id", studentID.String(), "error", err, "user_id", ownerID.String())
				return err
			}
			taken, err := qtx.ExistsStudentByOwnerIDAndFullNameAndIDNot(ctx, db.ExistsStudentByOwnerIDAndFullNameAndIDNotParams{
				OwnerID:  ownerID,
				FullName: trimmed,
				ID:       studentID,
			})
			if err != nil {
				logger.ErrorContext(ctx, "Failed to check student name uniqueness for update", "name", trimmed, "student_id", studentID.String(), "error", err, "user_id", ownerID.String())
				return err
			}
			if taken {
				logger.WarnContext(ctx, "Student name already exists for update", "name", trimmed, "student_id", studentID.String(), "user_id", ownerID.String())
				return pkgerrors.NewConflict(
					ErrNameNotUnique,
					fmt.Sprintf("A student named \"%s\" already exists", trimmed),
				)
			}
			fullName = trimmed
		}

		birthdate := existing.Birthdate
		if rawBD, ok := updates["birthdate"]; ok {
			if rawBD == nil {
				birthdate = sql.NullTime{Valid: false}
			} else if s, ok := rawBD.(string); ok && s != "" {
				t, err := time.Parse(time.DateOnly, s)
				if err != nil {
					t, err = time.Parse(time.RFC3339, s)
				}
				if err == nil {
					if err := validator.ValidateDateNotFuture(t, "birthdate"); err != nil {
						logger.WarnContext(ctx, "Updated student birthdate cannot be in the future", "birthdate", s, "user_id", ownerID.String())
						return err
					}
					birthdate = sql.NullTime{Time: t, Valid: true}
				}
			}
		}

		phone := existing.Phone
		if rawPhone, ok := updates["phone"]; ok {
			if rawPhone == nil {
				phone = sql.NullString{Valid: false}
			} else if s, ok := rawPhone.(string); ok {
				phone = sql.NullString{String: s, Valid: true}
			}
		}

		note := existing.Note
		if rawNote, ok := updates["note"]; ok {
			if rawNote == nil {
				note = sql.NullString{Valid: false}
			} else if s, ok := rawNote.(string); ok {
				note = sql.NullString{String: s, Valid: true}
			}
		}

		free := existing.Free
		if rawFree, ok := updates["free"]; ok && rawFree != nil {
			if b, ok := rawFree.(bool); ok {
				free = b
			}
		}

		groupKey := ""
		if _, ok := updates["groupIds"]; ok {
			groupKey = "groupIds"
		} else if _, ok := updates["groupId"]; ok {
			groupKey = "groupId"
		}

		if groupKey != "" && s.groupProvider != nil {
			requestedGroupIDs := types.ParseUUIDSlice(updates[groupKey])
			if err := s.groupProvider.SetStudentGroups(ctx, studentID, ownerID, requestedGroupIDs); err != nil {
				logger.ErrorContext(ctx, "Failed to set student groupIds", "student_id", studentID.String(), "error", err, "user_id", ownerID.String())
				return err
			}
		}

		updated, err = qtx.UpdateStudent(ctx, db.UpdateStudentParams{
			ID:        studentID,
			OwnerID:   ownerID,
			FullName:  fullName,
			Birthdate: birthdate,
			Phone:     phone,
			Note:      note,
			Free:      free,
		})
		if err != nil {
			logger.ErrorContext(ctx, "Failed to update student record", "student_id", studentID.String(), "error", err, "user_id", ownerID.String())
			return err
		}
		return nil
	})
	if err != nil {
		logger.ErrorContext(ctx, "Failed to update student transaction", "student_id", studentID.String(), "error", err, "user_id", ownerID.String())
		return response.StudentResponse{}, err
	}

	logger.InfoContext(ctx, "Student updated successfully", "student_id", updated.ID.String(), "name", updated.FullName, "user_id", ownerID.String())
	return toStudentResponse(updated), nil
}

func (s *Service) DeleteStudent(ctx context.Context, studentID, ownerID uuid.UUID) error {
	logger.InfoContext(ctx, "Deleting student", "student_id", studentID.String(), "user_id", ownerID.String())
	_, err := s.db.FindStudentByIDAndOwnerID(ctx, db.FindStudentByIDAndOwnerIDParams{
		ID:      studentID,
		OwnerID: ownerID,
	})
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			logger.WarnContext(ctx, "Student to delete not found", "student_id", studentID.String(), "user_id", ownerID.String())
			return pkgerrors.NewNotFound("Student", studentID, ownerID)
		}
		logger.ErrorContext(ctx, "Failed to find student for deletion", "student_id", studentID.String(), "error", err, "user_id", ownerID.String())
		return err
	}

	if err := s.db.DeleteStudentByIDAndOwnerID(ctx, db.DeleteStudentByIDAndOwnerIDParams{
		ID:      studentID,
		OwnerID: ownerID,
	}); err != nil {
		logger.ErrorContext(ctx, "Failed to delete student record", "student_id", studentID.String(), "error", err, "user_id", ownerID.String())
		return err
	}

	logger.InfoContext(ctx, "Student deleted successfully", "student_id", studentID.String(), "user_id", ownerID.String())
	return nil
}

func (s *Service) ComputeStudentStatuses(
	student response.StudentResponse,
	visits []visit.VisitResponse,
	payments []transaction.TransactionResponse,
	lessonsMap map[uuid.UUID]response.LessonResponse,
	groupLessonsMap map[uuid.UUID]response.LessonResponse,
	today time.Time,
) []StudentStatus {
	return ComputeStudentStatusesWithVisitLessons(student, visits, payments, lessonsMap, groupLessonsMap, today)
}
