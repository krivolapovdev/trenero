package student

import (
	"context"
	"database/sql"
	"errors"
	"fmt"
	"sort"
	"strings"
	"time"

	"github.com/google/uuid"
	"github.com/krivolapovdev/trenerio/internal/db"
	pkgerrors "github.com/krivolapovdev/trenerio/pkg/errors"
	"github.com/krivolapovdev/trenerio/pkg/logger"
	"github.com/krivolapovdev/trenerio/pkg/models"
	"github.com/krivolapovdev/trenerio/pkg/types"
)

type FetchVisitsByStudentIDsFunc func(ctx context.Context, studentIDs []uuid.UUID, ownerID uuid.UUID) (map[uuid.UUID][]models.VisitResponse, error)
type FetchVisitsByStudentIDFunc func(ctx context.Context, studentID, ownerID uuid.UUID) ([]models.VisitResponse, error)
type FetchPaymentsByStudentIDsFunc func(ctx context.Context, studentIDs []uuid.UUID, ownerID uuid.UUID) (map[uuid.UUID][]models.TransactionResponse, error)
type FetchPaymentsByStudentIDFunc func(ctx context.Context, studentID, ownerID uuid.UUID) ([]models.TransactionResponse, error)
type CreateStudentPaymentFunc func(ctx context.Context, studentID uuid.UUID, amount float64, date, paidUntil time.Time, ownerID uuid.UUID) (models.TransactionResponse, error)
type FetchStudentGroupsByStudentIDsFunc func(ctx context.Context, studentIDs []uuid.UUID, ownerID uuid.UUID) (map[uuid.UUID][]models.GroupResponse, error)
type SetStudentGroupsFunc func(ctx context.Context, studentID, ownerID uuid.UUID, groupIDs []uuid.UUID) error
type FetchLessonsByIDsFunc func(ctx context.Context, lessonIDs []uuid.UUID, ownerID uuid.UUID) ([]models.LessonResponse, error)

type Service struct {
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
) *Service {
	return &Service{
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

func (s *Service) GetAllStudents(ctx context.Context, ownerID uuid.UUID) ([]models.StudentResponse, error) {
	logger.InfoContext(ctx, "Getting all students", "user_id", ownerID.String())
	rows, err := s.db.FindAllStudentsByOwnerID(ctx, ownerID)
	if err != nil {
		logger.ErrorContext(ctx, "Failed to get all students", "error", err, "user_id", ownerID.String())
		return nil, err
	}
	res := make([]models.StudentResponse, 0, len(rows))
	for _, r := range rows {
		res = append(res, toStudentResponse(r))
	}
	logger.DebugContext(ctx, "Retrieved all students", "count", len(res), "user_id", ownerID.String())
	return res, nil
}

func (s *Service) GetStudentsByIDs(ctx context.Context, studentIDs []uuid.UUID, ownerID uuid.UUID) ([]models.StudentResponse, error) {
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
	res := make([]models.StudentResponse, 0, len(rows))
	for _, r := range rows {
		res = append(res, toStudentResponse(r))
	}
	logger.DebugContext(ctx, "Retrieved students by IDs", "count", len(res), "user_id", ownerID.String())
	return res, nil
}

func (s *Service) GetAllStudentsSummary(ctx context.Context, ownerID uuid.UUID) ([]models.StudentSummaryResponse, error) {
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

	visitsMap, err := s.fetchVisitsByStudentIDs(ctx, studentIDs, ownerID)
	if err != nil {
		logger.ErrorContext(ctx, "Failed to fetch visits for students overview", "error", err, "user_id", ownerID.String())
		return nil, err
	}

	lessonIDsMap := make(map[uuid.UUID]bool)
	for _, vs := range visitsMap {
		for _, v := range vs {
			lessonIDsMap[v.LessonID] = true
		}
	}

	paymentsMap, err := s.fetchPaymentsByStudentIDs(ctx, studentIDs, ownerID)
	if err != nil {
		logger.ErrorContext(ctx, "Failed to fetch payments for students overview", "error", err, "user_id", ownerID.String())
		return nil, err
	}

	studentGroupsMap, err := s.fetchStudentGroups(ctx, studentIDs, ownerID)
	if err != nil {
		logger.ErrorContext(ctx, "Failed to fetch student groups for overview", "error", err, "user_id", ownerID.String())
		return nil, err
	}

	allLessonIDs := make([]uuid.UUID, 0, len(lessonIDsMap))
	for lid := range lessonIDsMap {
		allLessonIDs = append(allLessonIDs, lid)
	}

	lessonsMap := make(map[uuid.UUID]models.LessonResponse)
	if len(allLessonIDs) > 0 {
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
	res := make([]models.StudentSummaryResponse, 0, len(students))
	for _, st := range students {
		stVisits := visitsMap[st.ID]
		stPayments := paymentsMap[st.ID]

		statuses := ComputeStudentStatuses(st, stVisits, stPayments, lessonsMap, today)
		stGroups := studentGroupsMap[st.ID]
		if stGroups == nil {
			stGroups = []models.GroupResponse{}
		}

		res = append(res, models.StudentSummaryResponse{
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

	logger.InfoContext(ctx, "Students overview generated successfully", "count", len(res), "user_id", ownerID.String())
	return res, nil
}

func (s *Service) GetStudentDetailsByID(ctx context.Context, studentID, ownerID uuid.UUID) (models.StudentResponse, error) {
	logger.InfoContext(ctx, "Getting student by id", "student_id", studentID.String(), "user_id", ownerID.String())
	st, err := s.db.FindStudentByIDAndOwnerID(ctx, db.FindStudentByIDAndOwnerIDParams{
		ID:      studentID,
		OwnerID: ownerID,
	})
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			logger.WarnContext(ctx, "Student not found", "student_id", studentID.String(), "user_id", ownerID.String())
			return models.StudentResponse{}, &pkgerrors.NotFoundError{
				Entity:  "Student",
				ID:      studentID,
				OwnerID: ownerID,
			}
		}
		logger.ErrorContext(ctx, "Failed to get student by id", "student_id", studentID.String(), "error", err, "user_id", ownerID.String())
		return models.StudentResponse{}, err
	}
	logger.DebugContext(ctx, "Retrieved student by id", "student_id", studentID.String(), "user_id", ownerID.String())
	return toStudentResponse(st), nil
}

func (s *Service) GetStudentVisits(ctx context.Context, studentID, ownerID uuid.UUID, from, to *time.Time) ([]models.VisitWithLessonResponse, error) {
	logger.InfoContext(ctx, "Getting student visits", "student_id", studentID.String(), "user_id", ownerID.String())
	_, err := s.GetStudentDetailsByID(ctx, studentID, ownerID)
	if err != nil {
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

	lessonsMap := make(map[uuid.UUID]models.LessonResponse)
	if len(lessonIDs) > 0 {
		lRows, err := s.fetchLessonsByIDs(ctx, lessonIDs, ownerID)
		if err != nil {
			logger.ErrorContext(ctx, "Failed to fetch lessons for student visits", "student_id", studentID.String(), "error", err, "user_id", ownerID.String())
			return nil, err
		}
		for _, lr := range lRows {
			lessonsMap[lr.ID] = lr
		}
	}

	res := make([]models.VisitWithLessonResponse, 0, len(vRows))
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
		res = append(res, models.VisitWithLessonResponse{
			Visit:  vr,
			Lesson: lResp,
		})
	}

	sort.Slice(res, func(i, j int) bool {
		return res[i].Lesson.Date.After(res[j].Lesson.Date)
	})

	logger.InfoContext(ctx, "Retrieved student visits",
		"student_id", studentID.String(),
		"total_visits", len(vRows),
		"filtered_visits", len(res),
		"user_id", ownerID.String(),
	)
	return res, nil
}

func (s *Service) GetStudentPayments(ctx context.Context, studentID, ownerID uuid.UUID) ([]models.TransactionResponse, error) {
	logger.InfoContext(ctx, "Getting payments for student", "student_id", studentID.String(), "user_id", ownerID.String())
	_, err := s.GetStudentDetailsByID(ctx, studentID, ownerID)
	if err != nil {
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

func (s *Service) CreateStudent(ctx context.Context, req models.CreateStudentRequest, ownerID uuid.UUID) (models.StudentResponse, error) {
	logger.InfoContext(ctx, "Creating student", "name", req.FullName, "user_id", ownerID.String())
	fullName := strings.TrimSpace(req.FullName)
	if fullName == "" {
		logger.WarnContext(ctx, "Student full name must not be blank", "user_id", ownerID.String())
		return models.StudentResponse{}, &pkgerrors.BadRequestError{Message: "fullName must not be blank"}
	}
	if len(fullName) > 255 {
		logger.WarnContext(ctx, "Student full name exceeds limit", "length", len(fullName), "user_id", ownerID.String())
		return models.StudentResponse{}, &pkgerrors.BadRequestError{Message: "fullName must not exceed 255 characters"}
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
		return models.StudentResponse{}, &pkgerrors.ConflictError{
			Code:    types.ErrStudentNameNotUnique,
			Message: fmt.Sprintf("A student named \"%s\" already exists", fullName),
		}
	}

	var birthdate sql.NullTime
	if req.Birthdate != nil {
		birthdate = sql.NullTime{Time: req.Birthdate.Time, Valid: true}
	}
	var phone sql.NullString
	if req.Phone != nil {
		phone = sql.NullString{String: *req.Phone, Valid: true}
	}
	var note sql.NullString
	if req.Note != nil {
		note = sql.NullString{String: *req.Note, Valid: true}
	}

	st, err := s.db.CreateStudent(ctx, db.CreateStudentParams{
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

	logger.InfoContext(ctx, "Student created successfully", "student_id", st.ID.String(), "name", st.FullName, "user_id", ownerID.String())
	return toStudentResponse(st), nil
}

func (s *Service) CreateStudentPayment(ctx context.Context, studentID uuid.UUID, ownerID uuid.UUID, req models.CreateStudentPaymentRequest) (models.TransactionResponse, error) {
	logger.InfoContext(ctx, "Creating student payment", "student_id", studentID.String(), "amount", req.Amount, "user_id", ownerID.String())
	_, err := s.GetStudentDetailsByID(ctx, studentID, ownerID)
	if err != nil {
		logger.WarnContext(ctx, "Student not found for payment", "student_id", studentID.String(), "error", err, "user_id", ownerID.String())
		return models.TransactionResponse{}, err
	}

	if req.PaidUntil.Before(req.Date) {
		logger.WarnContext(ctx, "paidUntil must not be before payment date", "student_id", studentID.String(), "paid_until", req.PaidUntil.Format(time.RFC3339), "date", req.Date.Format(time.RFC3339), "user_id", ownerID.String())
		return models.TransactionResponse{}, &pkgerrors.BadRequestError{
			Message: "paidUntil must not be before the payment date",
		}
	}

	res, err := s.createStudentPayment(ctx, studentID, req.Amount, req.Date, req.PaidUntil, ownerID)
	if err != nil {
		logger.ErrorContext(ctx, "Failed to create student payment", "student_id", studentID.String(), "error", err, "user_id", ownerID.String())
		return models.TransactionResponse{}, err
	}
	logger.InfoContext(ctx, "Student payment created successfully", "student_id", studentID.String(), "amount", req.Amount, "user_id", ownerID.String())
	return res, nil
}

func (s *Service) UpdateStudent(ctx context.Context, studentID, ownerID uuid.UUID, updates map[string]interface{}) (models.StudentResponse, error) {
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
				return &pkgerrors.NotFoundError{
					Entity:  "Student",
					ID:      studentID,
					OwnerID: ownerID,
				}
			}
			logger.ErrorContext(ctx, "Failed to find student for update", "student_id", studentID.String(), "error", err, "user_id", ownerID.String())
			return err
		}

		fullName := existing.FullName
		if rawName, ok := updates["fullName"]; ok && rawName != nil {
			nameStr, isStr := rawName.(string)
			if !isStr || strings.TrimSpace(nameStr) == "" {
				logger.WarnContext(ctx, "Updated student full name must not be blank", "student_id", studentID.String(), "user_id", ownerID.String())
				return &pkgerrors.BadRequestError{Message: "fullName must not be blank"}
			}
			trimmed := strings.TrimSpace(nameStr)
			if len(trimmed) > 255 {
				logger.WarnContext(ctx, "Updated student full name exceeds limit", "length", len(trimmed), "student_id", studentID.String(), "user_id", ownerID.String())
				return &pkgerrors.BadRequestError{Message: "fullName must not exceed 255 characters"}
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
				return &pkgerrors.ConflictError{
					Code:    types.ErrStudentNameNotUnique,
					Message: fmt.Sprintf("A student named \"%s\" already exists", trimmed),
				}
			}
			fullName = trimmed
		}

		birthdate := existing.Birthdate
		if rawBD, ok := updates["birthdate"]; ok {
			if rawBD == nil {
				birthdate = sql.NullTime{Valid: false}
			} else if s, ok := rawBD.(string); ok && s != "" {
				if t, err := time.Parse(time.DateOnly, s); err == nil {
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

		if _, ok := updates["groupIds"]; ok {
			requestedGroupIDs := parseUUIDSlice(updates["groupIds"])
			if err := s.setStudentGroups(ctx, studentID, ownerID, requestedGroupIDs); err != nil {
				logger.ErrorContext(ctx, "Failed to set student groupIds", "student_id", studentID.String(), "error", err, "user_id", ownerID.String())
				return err
			}
		} else if _, ok := updates["groupId"]; ok {
			requestedGroupIDs := parseUUIDSlice(updates["groupId"])
			if err := s.setStudentGroups(ctx, studentID, ownerID, requestedGroupIDs); err != nil {
				logger.ErrorContext(ctx, "Failed to set student groupId", "student_id", studentID.String(), "error", err, "user_id", ownerID.String())
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

func (s *Service) DeleteStudent(ctx context.Context, studentID, ownerID uuid.UUID) error {
	logger.InfoContext(ctx, "Deleting student", "student_id", studentID.String(), "user_id", ownerID.String())
	_, err := s.db.FindStudentByIDAndOwnerID(ctx, db.FindStudentByIDAndOwnerIDParams{
		ID:      studentID,
		OwnerID: ownerID,
	})
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			logger.WarnContext(ctx, "Student to delete not found", "student_id", studentID.String(), "user_id", ownerID.String())
			return &pkgerrors.NotFoundError{
				Entity:  "Student",
				ID:      studentID,
				OwnerID: ownerID,
			}
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
	student models.StudentResponse,
	visits []models.VisitResponse,
	payments []models.TransactionResponse,
	lessonsMap map[uuid.UUID]models.LessonResponse,
	groupLessonsMap map[uuid.UUID]models.LessonResponse,
	today time.Time,
) []types.StudentStatus {
	return ComputeStudentStatusesWithVisitLessons(student, visits, payments, lessonsMap, groupLessonsMap, today)
}

func ComputeStudentStatuses(
	student models.StudentResponse,
	visits []models.VisitResponse,
	payments []models.TransactionResponse,
	lessonsMap map[uuid.UUID]models.LessonResponse,
	today time.Time,
) []types.StudentStatus {
	return ComputeStudentStatusesWithVisitLessons(student, visits, payments, lessonsMap, lessonsMap, today)
}

func ComputeStudentStatusesWithVisitLessons(
	student models.StudentResponse,
	visits []models.VisitResponse,
	payments []models.TransactionResponse,
	lessonsMap map[uuid.UUID]models.LessonResponse,
	visitLessonsMap map[uuid.UUID]models.LessonResponse,
	today time.Time,
) []types.StudentStatus {
	if len(visits) == 0 && len(payments) == 0 {
		if student.Free {
			return []types.StudentStatus{types.StudentStatusFree}
		}
		return []types.StudentStatus{types.StudentStatusInactive}
	}

	statuses := make([]types.StudentStatus, 0)

	var lastVisitLesson *models.LessonResponse
	for _, l := range visitLessonsMap {
		if lastVisitLesson == nil {
			cur := l
			lastVisitLesson = &cur
		} else if l.Date.After(lastVisitLesson.Date) || (l.Date.Equal(lastVisitLesson.Date) && l.CreatedAt.After(lastVisitLesson.CreatedAt)) {
			cur := l
			lastVisitLesson = &cur
		}
	}

	if lastVisitLesson != nil {
		for _, v := range visits {
			if v.LessonID == lastVisitLesson.ID {
				if v.Status == types.VisitStatusPresent {
					statuses = append(statuses, types.StudentStatusPresent)
				} else {
					statuses = append(statuses, types.StudentStatusMissing)
				}
				break
			}
		}
	}

	if student.Free {
		statuses = append(statuses, types.StudentStatusFree)
		return statuses
	}

	var lastLesson *models.LessonResponse
	for _, l := range lessonsMap {
		if lastLesson == nil {
			cur := l
			lastLesson = &cur
		} else if l.Date.After(lastLesson.Date) || (l.Date.Equal(lastLesson.Date) && l.CreatedAt.After(lastLesson.CreatedAt)) {
			cur := l
			lastLesson = &cur
		}
	}

	referenceDate := today
	if lastLesson != nil {
		referenceDate = lastLesson.Date
	}

	var maxPaidUntil *time.Time
	for _, p := range payments {
		if p.PaymentDetails != nil {
			pu := p.PaymentDetails.PaidUntil
			if maxPaidUntil == nil || pu.After(*maxPaidUntil) {
				t := pu
				maxPaidUntil = &t
			}
		}
	}

	isSubscriptionActive := false
	if maxPaidUntil != nil && !maxPaidUntil.Before(referenceDate) {
		isSubscriptionActive = true
	}

	if isSubscriptionActive {
		statuses = append(statuses, types.StudentStatusPaid)
	} else {
		statuses = append(statuses, types.StudentStatusUnpaid)
	}

	return statuses
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

func parseUUIDSlice(raw interface{}) []uuid.UUID {
	if raw == nil {
		return nil
	}
	var res []uuid.UUID
	switch v := raw.(type) {
	case []uuid.UUID:
		return v
	case []string:
		for _, s := range v {
			if id, err := uuid.Parse(s); err == nil {
				res = append(res, id)
			}
		}
	case []interface{}:
		for _, item := range v {
			if s, ok := item.(string); ok {
				if id, err := uuid.Parse(s); err == nil {
					res = append(res, id)
				}
			}
		}
	}
	return res
}
