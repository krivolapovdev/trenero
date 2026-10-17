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
	pkgerrors "github.com/krivolapovdev/trenerio/pkg/errors"
	"github.com/krivolapovdev/trenerio/pkg/logger"
	"github.com/krivolapovdev/trenerio/pkg/models"
	"github.com/krivolapovdev/trenerio/pkg/types"
	"github.com/krivolapovdev/trenerio/pkg/utils"
	"golang.org/x/sync/errgroup"
)

type FetchVisitsByStudentIDsFunc func(ctx context.Context, studentIDs []uuid.UUID, ownerID uuid.UUID) (map[uuid.UUID][]models.VisitResponse, error)
type FetchVisitsByStudentIDFunc func(ctx context.Context, studentID, ownerID uuid.UUID) ([]models.VisitResponse, error)
type FetchPaymentsByStudentIDsFunc func(ctx context.Context, studentIDs []uuid.UUID, ownerID uuid.UUID) (map[uuid.UUID][]models.TransactionResponse, error)
type FetchPaymentsByStudentIDFunc func(ctx context.Context, studentID, ownerID uuid.UUID) ([]models.TransactionResponse, error)
type CreateStudentPaymentFunc func(ctx context.Context, studentID uuid.UUID, amount float64, date, paidUntil time.Time, ownerID uuid.UUID) (models.TransactionResponse, error)
type FetchStudentGroupsByStudentIDsFunc func(ctx context.Context, studentIDs []uuid.UUID, ownerID uuid.UUID) (map[uuid.UUID][]models.GroupResponse, error)
type SetStudentGroupsFunc func(ctx context.Context, studentID, ownerID uuid.UUID, groupIDs []uuid.UUID) error
type FetchLessonsByIDsFunc func(ctx context.Context, lessonIDs []uuid.UUID, ownerID uuid.UUID) ([]models.LessonResponse, error)

type Service interface {
	GetAllStudents(ctx context.Context, ownerID uuid.UUID) ([]models.StudentResponse, error)
	GetStudentsByIDs(ctx context.Context, studentIDs []uuid.UUID, ownerID uuid.UUID) ([]models.StudentResponse, error)
	GetAllStudentsSummary(ctx context.Context, ownerID uuid.UUID) ([]models.StudentSummaryResponse, error)
	GetStudentDetailsByID(ctx context.Context, studentID, ownerID uuid.UUID) (models.StudentResponse, error)
	GetStudentVisits(ctx context.Context, studentID, ownerID uuid.UUID, from, to *time.Time) ([]models.VisitWithLessonResponse, error)
	GetStudentPayments(ctx context.Context, studentID, ownerID uuid.UUID) ([]models.TransactionResponse, error)
	CreateStudent(ctx context.Context, req models.CreateStudentRequest, ownerID uuid.UUID) (models.StudentResponse, error)
	CreateStudentPayment(ctx context.Context, studentID, ownerID uuid.UUID, req models.CreateStudentPaymentRequest) (models.TransactionResponse, error)
	UpdateStudent(ctx context.Context, studentID, ownerID uuid.UUID, updates map[string]any) (models.StudentResponse, error)
	DeleteStudent(ctx context.Context, studentID, ownerID uuid.UUID) error
	ComputeStudentStatuses(student models.StudentResponse, visits []models.VisitResponse, payments []models.TransactionResponse, lessonsMap map[uuid.UUID]models.LessonResponse, groupLessonsMap map[uuid.UUID]models.LessonResponse, today time.Time) []types.StudentStatus
}

type service struct {
	db                        *db.Queries
	sqlDB                     *sql.DB
	fetchVisitsByStudentIDs   FetchVisitsByStudentIDsFunc
	fetchVisitsByStudentID    FetchVisitsByStudentIDFunc
	fetchPaymentsByStudentIDs FetchPaymentsByStudentIDsFunc
	fetchPaymentsByStudentID  FetchPaymentsByStudentIDFunc
	createStudentPayment      CreateStudentPaymentFunc
	fetchStudentGroups        FetchStudentGroupsByStudentIDsFunc
	setStudentGroups          SetStudentGroupsFunc
	fetchLessonsByIDs         FetchLessonsByIDsFunc
}

func NewService(
	queries *db.Queries,
	sqlDB *sql.DB,
	fetchVisitsByStudentIDs FetchVisitsByStudentIDsFunc,
	fetchVisitsByStudentID FetchVisitsByStudentIDFunc,
	fetchPaymentsByStudentIDs FetchPaymentsByStudentIDsFunc,
	fetchPaymentsByStudentID FetchPaymentsByStudentIDFunc,
	createStudentPayment CreateStudentPaymentFunc,
	fetchStudentGroups FetchStudentGroupsByStudentIDsFunc,
	setStudentGroups SetStudentGroupsFunc,
	fetchLessonsByIDs FetchLessonsByIDsFunc,
) Service {
	return &service{
		db:                        queries,
		sqlDB:                     sqlDB,
		fetchVisitsByStudentIDs:   fetchVisitsByStudentIDs,
		fetchVisitsByStudentID:    fetchVisitsByStudentID,
		fetchPaymentsByStudentIDs: fetchPaymentsByStudentIDs,
		fetchPaymentsByStudentID:  fetchPaymentsByStudentID,
		createStudentPayment:      createStudentPayment,
		fetchStudentGroups:        fetchStudentGroups,
		setStudentGroups:          setStudentGroups,
		fetchLessonsByIDs:         fetchLessonsByIDs,
	}
}

func (s *service) withTx(ctx context.Context, fn func(qtx *db.Queries) error) error {
	return db.WithTx(ctx, s.sqlDB, s.db, fn)
}

func (s *service) GetAllStudents(ctx context.Context, ownerID uuid.UUID) ([]models.StudentResponse, error) {
	logger.InfoContext(ctx, "Getting all students", "user_id", ownerID.String())
	rows, err := s.db.FindAllStudentsByOwnerID(ctx, ownerID)
	if err != nil {
		logger.ErrorContext(ctx, "Failed to get all students", "error", err, "user_id", ownerID.String())
		return nil, err
	}
	students := make([]models.StudentResponse, 0, len(rows))
	for _, r := range rows {
		students = append(students, toStudentResponse(r))
	}
	logger.DebugContext(ctx, "Retrieved all students", "count", len(students), "user_id", ownerID.String())
	return students, nil
}

func (s *service) GetStudentsByIDs(ctx context.Context, studentIDs []uuid.UUID, ownerID uuid.UUID) ([]models.StudentResponse, error) {
	if len(studentIDs) == 0 {
		logger.DebugContext(ctx, "No student IDs provided to get students", "user_id", ownerID.String())
		return []models.StudentResponse{}, nil
	}
	rows, err := s.db.FindStudentsByIDsAndOwnerID(ctx, db.FindStudentsByIDsAndOwnerIDParams{
		OwnerID: ownerID,
		Column2: studentIDs,
	})
	if err != nil {
		logger.ErrorContext(ctx, "Failed to get students by IDs", "count", len(studentIDs), "error", err, "user_id", ownerID.String())
		return nil, err
	}
	students := make([]models.StudentResponse, 0, len(rows))
	for _, r := range rows {
		students = append(students, toStudentResponse(r))
	}
	logger.DebugContext(ctx, "Retrieved students by IDs", "count", len(students), "user_id", ownerID.String())
	return students, nil
}

func (s *service) GetAllStudentsSummary(ctx context.Context, ownerID uuid.UUID) ([]models.StudentSummaryResponse, error) {
	logger.InfoContext(ctx, "Getting students overview", "user_id", ownerID.String())
	students, err := s.GetAllStudents(ctx, ownerID)
	if err != nil {
		logger.ErrorContext(ctx, "Failed to get students for overview", "error", err, "user_id", ownerID.String())
		return nil, err
	}
	if len(students) == 0 {
		logger.InfoContext(ctx, "No students found for overview", "user_id", ownerID.String())
		return []models.StudentSummaryResponse{}, nil
	}

	studentIDs := make([]uuid.UUID, 0, len(students))
	for _, st := range students {
		studentIDs = append(studentIDs, st.ID)
	}

	var (
		visitsMap        map[uuid.UUID][]models.VisitResponse
		paymentsMap      map[uuid.UUID][]models.TransactionResponse
		studentGroupsMap map[uuid.UUID][]models.GroupResponse
	)

	g, gCtx := errgroup.WithContext(ctx)
	if s.fetchVisitsByStudentIDs != nil {
		g.Go(func() error {
			vm, err := s.fetchVisitsByStudentIDs(gCtx, studentIDs, ownerID)
			if err != nil {
				return err
			}
			visitsMap = vm
			return nil
		})
	}
	if s.fetchPaymentsByStudentIDs != nil {
		g.Go(func() error {
			pm, err := s.fetchPaymentsByStudentIDs(gCtx, studentIDs, ownerID)
			if err != nil {
				return err
			}
			paymentsMap = pm
			return nil
		})
	}
	if s.fetchStudentGroups != nil {
		g.Go(func() error {
			gm, err := s.fetchStudentGroups(gCtx, studentIDs, ownerID)
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

	lessonsMap := make(map[uuid.UUID]models.LessonResponse, len(allLessonIDs))
	if len(allLessonIDs) > 0 && s.fetchLessonsByIDs != nil {
		lRows, err := s.fetchLessonsByIDs(ctx, allLessonIDs, ownerID)
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
	summaries := make([]models.StudentSummaryResponse, 0, len(students))
	for _, st := range students {
		stVisits := visitsMap[st.ID]
		stPayments := paymentsMap[st.ID]

		statuses := ComputeStudentStatuses(st, stVisits, stPayments, lessonsMap, today)
		stGroups := studentGroupsMap[st.ID]
		if stGroups == nil {
			stGroups = []models.GroupResponse{}
		}

		summaries = append(summaries, models.StudentSummaryResponse{
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

func (s *service) GetStudentDetailsByID(ctx context.Context, studentID, ownerID uuid.UUID) (models.StudentResponse, error) {
	logger.InfoContext(ctx, "Getting student by id", "student_id", studentID.String(), "user_id", ownerID.String())
	st, err := s.db.FindStudentByIDAndOwnerID(ctx, db.FindStudentByIDAndOwnerIDParams{
		ID:      studentID,
		OwnerID: ownerID,
	})
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			logger.WarnContext(ctx, "Student not found", "student_id", studentID.String(), "user_id", ownerID.String())
			return models.StudentResponse{}, pkgerrors.NewNotFound("Student", studentID, ownerID)
		}
		logger.ErrorContext(ctx, "Failed to get student by id", "student_id", studentID.String(), "error", err, "user_id", ownerID.String())
		return models.StudentResponse{}, err
	}
	logger.DebugContext(ctx, "Retrieved student by id", "student_id", studentID.String(), "user_id", ownerID.String())
	return toStudentResponse(st), nil
}

func (s *service) GetStudentVisits(ctx context.Context, studentID, ownerID uuid.UUID, from, to *time.Time) ([]models.VisitWithLessonResponse, error) {
	logger.InfoContext(ctx, "Getting student visits", "student_id", studentID.String(), "user_id", ownerID.String())
	if _, err := s.GetStudentDetailsByID(ctx, studentID, ownerID); err != nil {
		logger.WarnContext(ctx, "Student not found for visits", "student_id", studentID.String(), "error", err, "user_id", ownerID.String())
		return nil, err
	}

	vRows, err := s.fetchVisitsByStudentID(ctx, studentID, ownerID)
	if err != nil {
		logger.ErrorContext(ctx, "Failed to fetch student visits", "student_id", studentID.String(), "error", err, "user_id", ownerID.String())
		return nil, err
	}
	if len(vRows) == 0 {
		return []models.VisitWithLessonResponse{}, nil
	}

	lessonIDs := make([]uuid.UUID, 0, len(vRows))
	for _, vr := range vRows {
		lessonIDs = append(lessonIDs, vr.LessonID)
	}

	lessonsMap := make(map[uuid.UUID]models.LessonResponse, len(lessonIDs))
	if len(lessonIDs) > 0 && s.fetchLessonsByIDs != nil {
		lRows, err := s.fetchLessonsByIDs(ctx, lessonIDs, ownerID)
		if err != nil {
			logger.ErrorContext(ctx, "Failed to fetch lessons for student visits", "student_id", studentID.String(), "error", err, "user_id", ownerID.String())
			return nil, err
		}
		for _, lr := range lRows {
			lessonsMap[lr.ID] = lr
		}
	}

	visitsWithLessons := make([]models.VisitWithLessonResponse, 0, len(vRows))
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
		visitsWithLessons = append(visitsWithLessons, models.VisitWithLessonResponse{
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

func (s *service) GetStudentPayments(ctx context.Context, studentID, ownerID uuid.UUID) ([]models.TransactionResponse, error) {
	logger.InfoContext(ctx, "Getting payments for student", "student_id", studentID.String(), "user_id", ownerID.String())
	if _, err := s.GetStudentDetailsByID(ctx, studentID, ownerID); err != nil {
		logger.WarnContext(ctx, "Student not found for payments", "student_id", studentID.String(), "error", err, "user_id", ownerID.String())
		return nil, err
	}

	payments, err := s.fetchPaymentsByStudentID(ctx, studentID, ownerID)
	if err != nil {
		logger.ErrorContext(ctx, "Failed to fetch student payments", "student_id", studentID.String(), "error", err, "user_id", ownerID.String())
		return nil, err
	}
	logger.InfoContext(ctx, "Retrieved student payments", "student_id", studentID.String(), "count", len(payments), "user_id", ownerID.String())
	return payments, nil
}

func (s *service) CreateStudent(ctx context.Context, req models.CreateStudentRequest, ownerID uuid.UUID) (models.StudentResponse, error) {
	logger.InfoContext(ctx, "Creating student", "name", req.FullName, "user_id", ownerID.String())
	fullName, err := utils.ValidateRequiredName(req.FullName, "fullName")
	if err != nil {
		logger.WarnContext(ctx, "Student full name validation failed", "user_id", ownerID.String())
		return models.StudentResponse{}, err
	}

	var birthdate sql.NullTime
	if req.Birthdate != nil {
		if err := utils.ValidateDateNotFuture(req.Birthdate.Time, "birthdate"); err != nil {
			logger.WarnContext(ctx, "Student birthdate cannot be in the future", "birthdate", req.Birthdate.Format(time.DateOnly), "user_id", ownerID.String())
			return models.StudentResponse{}, err
		}
		birthdate = sql.NullTime{Time: req.Birthdate.Time, Valid: true}
	}

	taken, err := s.db.ExistsStudentByOwnerIDAndFullName(ctx, db.ExistsStudentByOwnerIDAndFullNameParams{
		OwnerID:  ownerID,
		FullName: fullName,
	})
	if err != nil {
		logger.ErrorContext(ctx, "Failed to check student name uniqueness", "name", fullName, "error", err, "user_id", ownerID.String())
		return models.StudentResponse{}, err
	}
	if taken {
		logger.WarnContext(ctx, "Student with name already exists", "name", fullName, "user_id", ownerID.String())
		return models.StudentResponse{}, pkgerrors.NewConflict(
			types.ErrStudentNameNotUnique,
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
		return models.StudentResponse{}, err
	}

	logger.InfoContext(ctx, "Student created successfully", "student_id", created.ID.String(), "name", created.FullName, "user_id", ownerID.String())
	return toStudentResponse(created), nil
}

func (s *service) CreateStudentPayment(ctx context.Context, studentID, ownerID uuid.UUID, req models.CreateStudentPaymentRequest) (models.TransactionResponse, error) {
	logger.InfoContext(ctx, "Creating payment for student", "student_id", studentID.String(), "amount", req.Amount, "user_id", ownerID.String())
	if err := utils.ValidateDateNotFuture(req.Date, "date"); err != nil {
		logger.WarnContext(ctx, "Student payment date cannot be in the future", "date", req.Date.Format(time.RFC3339), "user_id", ownerID.String())
		return models.TransactionResponse{}, err
	}

	if _, err := s.GetStudentDetailsByID(ctx, studentID, ownerID); err != nil {
		logger.WarnContext(ctx, "Student not found for creating payment", "student_id", studentID.String(), "error", err, "user_id", ownerID.String())
		return models.TransactionResponse{}, err
	}

	payment, err := s.createStudentPayment(ctx, studentID, req.Amount, req.Date, req.PaidUntil, ownerID)
	if err != nil {
		logger.ErrorContext(ctx, "Failed to create payment for student", "student_id", studentID.String(), "error", err, "user_id", ownerID.String())
		return models.TransactionResponse{}, err
	}

	logger.InfoContext(ctx, "Student payment created successfully", "student_id", studentID.String(), "transaction_id", payment.ID.String(), "user_id", ownerID.String())
	return payment, nil
}

func (s *service) UpdateStudent(ctx context.Context, studentID, ownerID uuid.UUID, updates map[string]any) (models.StudentResponse, error) {
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
			trimmed, err := utils.ValidateRequiredName(nameStr, "fullName")
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
					types.ErrStudentNameNotUnique,
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
					if err := utils.ValidateDateNotFuture(t, "birthdate"); err != nil {
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

		if groupKey != "" && s.setStudentGroups != nil {
			requestedGroupIDs := types.ParseUUIDSlice(updates[groupKey])
			if err := s.setStudentGroups(ctx, studentID, ownerID, requestedGroupIDs); err != nil {
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
		return models.StudentResponse{}, err
	}

	logger.InfoContext(ctx, "Student updated successfully", "student_id", updated.ID.String(), "name", updated.FullName, "user_id", ownerID.String())
	return toStudentResponse(updated), nil
}

func (s *service) DeleteStudent(ctx context.Context, studentID, ownerID uuid.UUID) error {
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

func (s *service) ComputeStudentStatuses(
	student models.StudentResponse,
	visits []models.VisitResponse,
	payments []models.TransactionResponse,
	lessonsMap map[uuid.UUID]models.LessonResponse,
	groupLessonsMap map[uuid.UUID]models.LessonResponse,
	today time.Time,
) []types.StudentStatus {
	return ComputeStudentStatusesWithVisitLessons(student, visits, payments, lessonsMap, groupLessonsMap, today)
}

func toStudentResponse(s db.StudentsModuleStudent) models.StudentResponse {
	var birthdate *types.Date
	if s.Birthdate.Valid {
		birthdate = &types.Date{Time: s.Birthdate.Time}
	}
	var phone *string
	if s.Phone.Valid {
		phone = &s.Phone.String
	}
	var note *string
	if s.Note.Valid {
		note = &s.Note.String
	}
	return models.StudentResponse{
		ID:        s.ID,
		FullName:  s.FullName,
		Birthdate: birthdate,
		Phone:     phone,
		Note:      note,
		CreatedAt: s.CreatedAt,
		Free:      s.Free,
	}
}
