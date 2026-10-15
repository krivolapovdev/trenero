package student

import (
	"context"
	"database/sql"
	"errors"
	"fmt"
	"sort"
	"strconv"
	"strings"
	"time"

	"github.com/google/uuid"
	"github.com/krivolapovdev/trenerio/internal/db"
	pkgerrors "github.com/krivolapovdev/trenerio/pkg/errors"
	"github.com/krivolapovdev/trenerio/pkg/logger"
	"github.com/krivolapovdev/trenerio/pkg/models"
	"github.com/krivolapovdev/trenerio/pkg/types"
)

type StudentService struct {
	db    *db.Queries
	sqlDB *sql.DB
}

func NewStudentService(queries *db.Queries, sqlDB *sql.DB) *StudentService {
	return &StudentService{
		db:    queries,
		sqlDB: sqlDB,
	}
}

func (s *StudentService) withTx(ctx context.Context, fn func(qtx *db.Queries) error) error {
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

func (s *StudentService) GetAllStudents(ctx context.Context, ownerID uuid.UUID) ([]models.StudentResponse, error) {
	logger.InfoContext(ctx, "Getting all students", "user_id", ownerID.String())
	rows, err := s.db.FindAllStudentsByOwnerID(ctx, ownerID)
	if err != nil {
		return nil, err
	}
	res := make([]models.StudentResponse, 0, len(rows))
	for _, r := range rows {
		res = append(res, toStudentResponse(r))
	}
	return res, nil
}

func (s *StudentService) GetAllStudentsSummary(ctx context.Context, ownerID uuid.UUID) ([]models.StudentSummaryResponse, error) {
	logger.InfoContext(ctx, "Getting students overview", "user_id", ownerID.String())
	students, err := s.GetAllStudents(ctx, ownerID)
	if err != nil {
		return nil, err
	}
	if len(students) == 0 {
		return []models.StudentSummaryResponse{}, nil
	}

	studentIDs := make([]uuid.UUID, 0, len(students))
	for _, st := range students {
		studentIDs = append(studentIDs, st.ID)
	}

	visitRows, err := s.db.FindVisitsByStudentIDsAndOwnerID(ctx, db.FindVisitsByStudentIDsAndOwnerIDParams{
		OwnerID: ownerID,
		Column2: studentIDs,
	})
	if err != nil {
		return nil, err
	}

	visitsMap := make(map[uuid.UUID][]models.VisitResponse)
	lessonIDsMap := make(map[uuid.UUID]bool)
	for _, vr := range visitRows {
		visitsMap[vr.StudentID] = append(visitsMap[vr.StudentID], models.VisitResponse{
			ID:        vr.ID,
			Status:    types.VisitStatus(vr.Status),
			Type:      types.VisitType(vr.Type),
			LessonID:  vr.LessonID,
			StudentID: vr.StudentID,
			CreatedAt: vr.CreatedAt,
		})
		lessonIDsMap[vr.LessonID] = true
	}

	paymentRows, err := s.db.FindStudentPaymentsByStudentIDsAndOwnerID(ctx, db.FindStudentPaymentsByStudentIDsAndOwnerIDParams{
		OwnerID: ownerID,
		Column2: studentIDs,
	})
	if err != nil {
		return nil, err
	}

	paymentsMap := make(map[uuid.UUID][]models.TransactionResponse)
	for _, pr := range paymentRows {
		amt, _ := strconv.ParseFloat(pr.Amount, 64)
		paymentsMap[pr.StudentID] = append(paymentsMap[pr.StudentID], models.TransactionResponse{
			ID:        pr.ID,
			Amount:    amt,
			Date:      pr.Date,
			Type:      types.TransactionType(pr.Type),
			CreatedAt: pr.CreatedAt,
			PaymentDetails: &models.StudentPaymentDetailsResponse{
				DetailsType: "STUDENT",
				StudentID:   pr.StudentID,
				PaidUntil:   pr.PaidUntil,
			},
		})
	}

	groupStudentRows, err := s.db.FindGroupStudentsByStudentIDsAndOwnerID(ctx, db.FindGroupStudentsByStudentIDsAndOwnerIDParams{
		OwnerID: ownerID,
		Column2: studentIDs,
	})
	if err != nil {
		return nil, err
	}

	studentGroupIDsMap := make(map[uuid.UUID][]uuid.UUID)
	allGroupIDsMap := make(map[uuid.UUID]bool)
	for _, gsr := range groupStudentRows {
		studentGroupIDsMap[gsr.StudentID] = append(studentGroupIDsMap[gsr.StudentID], gsr.GroupID)
		allGroupIDsMap[gsr.GroupID] = true
	}

	allGroupIDs := make([]uuid.UUID, 0, len(allGroupIDsMap))
	for gid := range allGroupIDsMap {
		allGroupIDs = append(allGroupIDs, gid)
	}

	groupsMap := make(map[uuid.UUID]models.GroupResponse)
	if len(allGroupIDs) > 0 {
		gRows, err := s.db.FindGroupsByIDsAndOwnerID(ctx, db.FindGroupsByIDsAndOwnerIDParams{
			OwnerID: ownerID,
			Column2: allGroupIDs,
		})
		if err != nil {
			return nil, err
		}
		for _, gr := range gRows {
			var defPrice *float64
			if gr.DefaultPrice.Valid {
				f, _ := strconv.ParseFloat(gr.DefaultPrice.String, 64)
				defPrice = &f
			}
			var note *string
			if gr.Note.Valid {
				note = &gr.Note.String
			}
			groupsMap[gr.ID] = models.GroupResponse{
				ID:           gr.ID,
				Name:         gr.Name,
				DefaultPrice: defPrice,
				Note:         note,
				CreatedAt:    gr.CreatedAt,
			}
		}
	}

	allLessonIDs := make([]uuid.UUID, 0, len(lessonIDsMap))
	for lid := range lessonIDsMap {
		allLessonIDs = append(allLessonIDs, lid)
	}

	lessonsMap := make(map[uuid.UUID]models.LessonResponse)
	if len(allLessonIDs) > 0 {
		lRows, err := s.db.FindLessonsByIDsAndOwnerID(ctx, db.FindLessonsByIDsAndOwnerIDParams{
			OwnerID: ownerID,
			Column2: allLessonIDs,
		})
		if err != nil {
			return nil, err
		}
		for _, lr := range lRows {
			var gID *uuid.UUID
			if lr.GroupID.Valid {
				gID = &lr.GroupID.UUID
			}
			lessonsMap[lr.ID] = models.LessonResponse{
				ID:        lr.ID,
				Date:      lr.Date,
				CreatedAt: lr.CreatedAt,
				GroupID:   gID,
			}
		}
	}

	today := time.Now().UTC()
	res := make([]models.StudentSummaryResponse, 0, len(students))
	for _, st := range students {
		stVisits := visitsMap[st.ID]
		stPayments := paymentsMap[st.ID]

		statuses := ComputeStudentStatuses(st, stVisits, stPayments, lessonsMap, today)

		gIDs := studentGroupIDsMap[st.ID]
		stGroups := make([]models.GroupResponse, 0, len(gIDs))
		for _, gid := range gIDs {
			if grp, ok := groupsMap[gid]; ok {
				stGroups = append(stGroups, grp)
			}
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

	return res, nil
}

func (s *StudentService) GetStudentDetailsByID(ctx context.Context, studentID, ownerID uuid.UUID) (models.StudentResponse, error) {
	logger.InfoContext(ctx, "Getting student by id", "student_id", studentID.String(), "user_id", ownerID.String())
	st, err := s.db.FindStudentByIDAndOwnerID(ctx, db.FindStudentByIDAndOwnerIDParams{
		ID:      studentID,
		OwnerID: ownerID,
	})
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return models.StudentResponse{}, &pkgerrors.NotFoundError{
				Entity:  "Student",
				ID:      studentID,
				OwnerID: ownerID,
			}
		}
		return models.StudentResponse{}, err
	}
	return toStudentResponse(st), nil
}

func (s *StudentService) GetStudentVisits(ctx context.Context, studentID, ownerID uuid.UUID, from, to *time.Time) ([]models.VisitWithLessonResponse, error) {
	logger.InfoContext(ctx, "Getting student visits", "student_id", studentID.String(), "user_id", ownerID.String())
	_, err := s.GetStudentDetailsByID(ctx, studentID, ownerID)
	if err != nil {
		return nil, err
	}

	vRows, err := s.db.FindVisitsByStudentIDAndOwnerID(ctx, db.FindVisitsByStudentIDAndOwnerIDParams{
		StudentID: studentID,
		OwnerID:   ownerID,
	})
	if err != nil {
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
		lRows, err := s.db.FindLessonsByIDsAndOwnerID(ctx, db.FindLessonsByIDsAndOwnerIDParams{
			OwnerID: ownerID,
			Column2: lessonIDs,
		})
		if err != nil {
			return nil, err
		}
		for _, lr := range lRows {
			var gID *uuid.UUID
			if lr.GroupID.Valid {
				gID = &lr.GroupID.UUID
			}
			lessonsMap[lr.ID] = models.LessonResponse{
				ID:        lr.ID,
				Date:      lr.Date,
				CreatedAt: lr.CreatedAt,
				GroupID:   gID,
			}
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
			Visit: models.VisitResponse{
				ID:        vr.ID,
				Status:    types.VisitStatus(vr.Status),
				Type:      types.VisitType(vr.Type),
				LessonID:  vr.LessonID,
				StudentID: vr.StudentID,
				CreatedAt: vr.CreatedAt,
			},
			Lesson: lResp,
		})
	}

	sort.Slice(res, func(i, j int) bool {
		return res[i].Lesson.Date.After(res[j].Lesson.Date)
	})

	return res, nil
}

func (s *StudentService) GetStudentPayments(ctx context.Context, studentID, ownerID uuid.UUID) ([]models.TransactionResponse, error) {
	logger.InfoContext(ctx, "Getting payments for student", "student_id", studentID.String(), "user_id", ownerID.String())
	_, err := s.GetStudentDetailsByID(ctx, studentID, ownerID)
	if err != nil {
		return nil, err
	}

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

func (s *StudentService) CreateStudent(ctx context.Context, req models.CreateStudentRequest, ownerID uuid.UUID) (models.StudentResponse, error) {
	logger.InfoContext(ctx, "Creating student", "name", req.FullName, "user_id", ownerID.String())
	fullName := strings.TrimSpace(req.FullName)
	if fullName == "" {
		return models.StudentResponse{}, &pkgerrors.BadRequestError{Message: "fullName must not be blank"}
	}
	if len(fullName) > 255 {
		return models.StudentResponse{}, &pkgerrors.BadRequestError{Message: "fullName must not exceed 255 characters"}
	}

	taken, err := s.db.ExistsStudentByOwnerIDAndFullName(ctx, db.ExistsStudentByOwnerIDAndFullNameParams{
		OwnerID:  ownerID,
		FullName: fullName,
	})
	if err != nil {
		return models.StudentResponse{}, err
	}
	if taken {
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
		return models.StudentResponse{}, err
	}

	return toStudentResponse(st), nil
}

func (s *StudentService) CreateStudentPayment(ctx context.Context, studentID uuid.UUID, ownerID uuid.UUID, req models.CreateStudentPaymentRequest) (models.TransactionResponse, error) {
	logger.InfoContext(ctx, "Creating student payment", "student_id", studentID.String(), "user_id", ownerID.String())
	_, err := s.db.FindStudentByIDAndOwnerID(ctx, db.FindStudentByIDAndOwnerIDParams{
		ID:      studentID,
		OwnerID: ownerID,
	})
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return models.TransactionResponse{}, &pkgerrors.NotFoundError{
				Entity:  "Student",
				ID:      studentID,
				OwnerID: ownerID,
			}
		}
		return models.TransactionResponse{}, err
	}

	if req.PaidUntil.Before(req.Date) {
		return models.TransactionResponse{}, &pkgerrors.BadRequestError{
			Message: "paidUntil must not be before the payment date",
		}
	}

	var createdTx db.PaymentsModuleTransaction
	var sp db.PaymentsModuleStudentPayment

	err = s.withTx(ctx, func(qtx *db.Queries) error {
		amountStr := strconv.FormatFloat(req.Amount, 'f', 2, 64)
		var err error
		createdTx, err = qtx.CreateTransaction(ctx, db.CreateTransactionParams{
			OwnerID: ownerID,
			Type:    db.PaymentsModuleTransactionTypeINCOME,
			Amount:  amountStr,
			Date:    req.Date,
		})
		if err != nil {
			return err
		}

		sp, err = qtx.CreateStudentPayment(ctx, db.CreateStudentPaymentParams{
			TransactionID: createdTx.ID,
			StudentID:     studentID,
			PaidUntil:     req.PaidUntil,
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

func (s *StudentService) UpdateStudent(ctx context.Context, studentID, ownerID uuid.UUID, updates map[string]interface{}) (models.StudentResponse, error) {
	logger.InfoContext(ctx, "Updating student", "student_id", studentID.String(), "user_id", ownerID.String())
	var updated db.StudentsModuleStudent

	err := s.withTx(ctx, func(qtx *db.Queries) error {
		existing, err := qtx.FindStudentByIDAndOwnerID(ctx, db.FindStudentByIDAndOwnerIDParams{
			ID:      studentID,
			OwnerID: ownerID,
		})
		if err != nil {
			if errors.Is(err, sql.ErrNoRows) {
				return &pkgerrors.NotFoundError{
					Entity:  "Student",
					ID:      studentID,
					OwnerID: ownerID,
				}
			}
			return err
		}

		fullName := existing.FullName
		if rawName, ok := updates["fullName"]; ok && rawName != nil {
			nameStr, isStr := rawName.(string)
			if !isStr || strings.TrimSpace(nameStr) == "" {
				return &pkgerrors.BadRequestError{Message: "fullName must not be blank"}
			}
			trimmed := strings.TrimSpace(nameStr)
			if len(trimmed) > 255 {
				return &pkgerrors.BadRequestError{Message: "fullName must not exceed 255 characters"}
			}
			taken, err := qtx.ExistsStudentByOwnerIDAndFullNameAndIDNot(ctx, db.ExistsStudentByOwnerIDAndFullNameAndIDNotParams{
				OwnerID:  ownerID,
				FullName: trimmed,
				ID:       studentID,
			})
			if err != nil {
				return err
			}
			if taken {
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
				if t, err := time.Parse("2006-01-02", s); err == nil {
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
			if err := reconcileStudentGroups(ctx, qtx, studentID, ownerID, requestedGroupIDs); err != nil {
				return err
			}
		} else if _, ok := updates["groupId"]; ok {
			requestedGroupIDs := parseUUIDSlice(updates["groupId"])
			if err := reconcileStudentGroups(ctx, qtx, studentID, ownerID, requestedGroupIDs); err != nil {
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
		return err
	})
	if err != nil {
		return models.StudentResponse{}, err
	}

	return toStudentResponse(updated), nil
}

func reconcileStudentGroups(ctx context.Context, qtx *db.Queries, studentID, ownerID uuid.UUID, requestedGroupIDs []uuid.UUID) error {
	currentLinks, err := qtx.FindGroupStudentsByStudentIDAndOwnerID(ctx, db.FindGroupStudentsByStudentIDAndOwnerIDParams{
		StudentID: studentID,
		OwnerID:   ownerID,
	})
	if err != nil {
		return err
	}

	reqMap := make(map[uuid.UUID]bool)
	for _, gid := range requestedGroupIDs {
		reqMap[gid] = true
	}

	for _, cl := range currentLinks {
		if !reqMap[cl.GroupID] {
			if err := qtx.DeleteGroupStudentByStudentAndGroupID(ctx, db.DeleteGroupStudentByStudentAndGroupIDParams{
				GroupID:   cl.GroupID,
				StudentID: studentID,
				OwnerID:   ownerID,
			}); err != nil {
				return err
			}
		}
	}

	curMap := make(map[uuid.UUID]bool)
	for _, cl := range currentLinks {
		curMap[cl.GroupID] = true
	}

	for _, gid := range requestedGroupIDs {
		if !curMap[gid] {
			_, err := qtx.CreateGroupStudent(ctx, db.CreateGroupStudentParams{
				OwnerID:   ownerID,
				GroupID:   gid,
				StudentID: studentID,
			})
			if err != nil {
				return err
			}
		}
	}

	return nil
}

func (s *StudentService) DeleteStudent(ctx context.Context, studentID, ownerID uuid.UUID) error {
	logger.InfoContext(ctx, "Deleting student", "student_id", studentID.String(), "user_id", ownerID.String())
	_, err := s.db.FindStudentByIDAndOwnerID(ctx, db.FindStudentByIDAndOwnerIDParams{
		ID:      studentID,
		OwnerID: ownerID,
	})
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return &pkgerrors.NotFoundError{
				Entity:  "Student",
				ID:      studentID,
				OwnerID: ownerID,
			}
		}
		return err
	}
	return s.db.DeleteStudentByIDAndOwnerID(ctx, db.DeleteStudentByIDAndOwnerIDParams{
		ID:      studentID,
		OwnerID: ownerID,
	})
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
	case string:
		if id, err := uuid.Parse(v); err == nil {
			res = append(res, id)
		}
	}
	return res
}
