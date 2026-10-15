package group

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
	"github.com/krivolapovdev/trenerio/internal/student"
	pkgerrors "github.com/krivolapovdev/trenerio/pkg/errors"
	"github.com/krivolapovdev/trenerio/pkg/logger"
	"github.com/krivolapovdev/trenerio/pkg/models"
	"github.com/krivolapovdev/trenerio/pkg/types"
)

type Service struct {
	db    *db.Queries
	sqlDB *sql.DB
}

func NewService(queries *db.Queries, sqlDB *sql.DB) *Service {
	return &Service{
		db:    queries,
		sqlDB: sqlDB,
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

func (s *Service) GetAllGroupsSummary(ctx context.Context, ownerID uuid.UUID) ([]models.GroupSummaryResponse, error) {
	logger.InfoContext(ctx, "Getting all groups summary", "user_id", ownerID.String())
	groups, err := s.db.FindAllGroupsByOwnerID(ctx, ownerID)
	if err != nil {
		return nil, err
	}
	if len(groups) == 0 {
		return []models.GroupSummaryResponse{}, nil
	}

	groupIDs := make([]uuid.UUID, 0, len(groups))
	for _, g := range groups {
		groupIDs = append(groupIDs, g.ID)
	}

	counts, err := s.db.CountStudentsByGroupIDs(ctx, db.CountStudentsByGroupIDsParams{
		OwnerID: ownerID,
		Column2: groupIDs,
	})
	if err != nil {
		return nil, err
	}

	countMap := make(map[uuid.UUID]int64)
	for _, c := range counts {
		countMap[c.GroupID] = c.StudentCount
	}

	res := make([]models.GroupSummaryResponse, 0, len(groups))
	for _, g := range groups {
		var defPrice *float64
		if g.DefaultPrice.Valid {
			f, _ := strconv.ParseFloat(g.DefaultPrice.String, 64)
			defPrice = &f
		}
		var note *string
		if g.Note.Valid {
			note = &g.Note.String
		}
		res = append(res, models.GroupSummaryResponse{
			ID:              g.ID,
			Name:            g.Name,
			DefaultPrice:    defPrice,
			Note:            note,
			CreatedAt:       g.CreatedAt,
			CountOfStudents: countMap[g.ID],
		})
	}

	return res, nil
}

func (s *Service) GetGroupByID(ctx context.Context, groupID, ownerID uuid.UUID) (models.GroupResponse, error) {
	logger.InfoContext(ctx, "Getting group by id", "group_id", groupID.String(), "user_id", ownerID.String())
	g, err := s.db.FindGroupByIDAndOwnerID(ctx, db.FindGroupByIDAndOwnerIDParams{
		ID:      groupID,
		OwnerID: ownerID,
	})
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return models.GroupResponse{}, &pkgerrors.NotFoundError{
				Entity:  "Group",
				ID:      groupID,
				OwnerID: ownerID,
			}
		}
		return models.GroupResponse{}, err
	}
	return toGroupResponse(g), nil
}

func (s *Service) GetGroupStudents(ctx context.Context, groupID, ownerID uuid.UUID) ([]models.GroupStudentSummaryResponse, error) {
	logger.InfoContext(ctx, "Getting students for group", "group_id", groupID.String(), "user_id", ownerID.String())
	_, err := s.GetGroupByID(ctx, groupID, ownerID)
	if err != nil {
		return nil, err
	}

	studentLinks, err := s.db.FindGroupStudentsByGroupIDAndOwnerID(ctx, db.FindGroupStudentsByGroupIDAndOwnerIDParams{
		GroupID: groupID,
		OwnerID: ownerID,
	})
	if err != nil {
		return nil, err
	}
	if len(studentLinks) == 0 {
		return []models.GroupStudentSummaryResponse{}, nil
	}

	studentIDs := make([]uuid.UUID, 0, len(studentLinks))
	seenStudentIDs := make(map[uuid.UUID]bool)
	for _, sl := range studentLinks {
		if !seenStudentIDs[sl.StudentID] {
			seenStudentIDs[sl.StudentID] = true
			studentIDs = append(studentIDs, sl.StudentID)
		}
	}

	stRows, err := s.db.FindStudentsByIDsAndOwnerID(ctx, db.FindStudentsByIDsAndOwnerIDParams{
		OwnerID: ownerID,
		Column2: studentIDs,
	})
	if err != nil {
		return nil, err
	}
	studentsMap := make(map[uuid.UUID]models.StudentResponse)
	for _, sr := range stRows {
		var birthdate *types.Date
		if sr.Birthdate.Valid {
			birthdate = &types.Date{Time: sr.Birthdate.Time}
		}
		var phone *string
		if sr.Phone.Valid {
			phone = &sr.Phone.String
		}
		var note *string
		if sr.Note.Valid {
			note = &sr.Note.String
		}
		studentsMap[sr.ID] = models.StudentResponse{
			ID:        sr.ID,
			FullName:  sr.FullName,
			Birthdate: birthdate,
			Phone:     phone,
			Note:      note,
			CreatedAt: sr.CreatedAt,
			Free:      sr.Free,
		}
	}

	vRows, err := s.db.FindVisitsByStudentIDsAndOwnerID(ctx, db.FindVisitsByStudentIDsAndOwnerIDParams{
		OwnerID: ownerID,
		Column2: studentIDs,
	})
	if err != nil {
		return nil, err
	}
	visitsByStudentID := make(map[uuid.UUID][]models.VisitResponse)
	allLessonIDsMap := make(map[uuid.UUID]bool)
	for _, vr := range vRows {
		visitsByStudentID[vr.StudentID] = append(visitsByStudentID[vr.StudentID], models.VisitResponse{
			ID:        vr.ID,
			Status:    types.VisitStatus(vr.Status),
			Type:      types.VisitType(vr.Type),
			LessonID:  vr.LessonID,
			StudentID: vr.StudentID,
			CreatedAt: vr.CreatedAt,
		})
		allLessonIDsMap[vr.LessonID] = true
	}

	pRows, err := s.db.FindStudentPaymentsByStudentIDsAndOwnerID(ctx, db.FindStudentPaymentsByStudentIDsAndOwnerIDParams{
		OwnerID: ownerID,
		Column2: studentIDs,
	})
	if err != nil {
		return nil, err
	}
	paymentsByStudentID := make(map[uuid.UUID][]models.TransactionResponse)
	for _, pr := range pRows {
		amt, _ := strconv.ParseFloat(pr.Amount, 64)
		paymentsByStudentID[pr.StudentID] = append(paymentsByStudentID[pr.StudentID], models.TransactionResponse{
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

	allLessonIDs := make([]uuid.UUID, 0, len(allLessonIDsMap))
	for lid := range allLessonIDsMap {
		allLessonIDs = append(allLessonIDs, lid)
	}

	lessonsMap := make(map[uuid.UUID]models.LessonResponse)
	if len(allLessonIDs) > 0 {
		lRows, err := s.db.FindLessonsByIDsAndOwnerID(ctx, db.FindLessonsByIDsAndOwnerIDParams{
			OwnerID: ownerID,
			Column2: allLessonIDs,
		})
		if err == nil {
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
	}

	today := time.Now().UTC()
	res := make([]models.GroupStudentSummaryResponse, 0, len(studentIDs))
	for _, sid := range studentIDs {
		st, ok := studentsMap[sid]
		if !ok {
			continue
		}
		stVisits := visitsByStudentID[sid]
		stPayments := paymentsByStudentID[sid]
		groupLessonsMap := make(map[uuid.UUID]models.LessonResponse)
		for lid, l := range lessonsMap {
			if l.GroupID != nil && *l.GroupID == groupID {
				groupLessonsMap[lid] = l
			}
		}
		statuses := student.ComputeStudentStatusesWithVisitLessons(st, stVisits, stPayments, lessonsMap, groupLessonsMap, today)

		res = append(res, models.GroupStudentSummaryResponse{
			ID:        st.ID,
			FullName:  st.FullName,
			Birthdate: st.Birthdate,
			Phone:     st.Phone,
			Note:      st.Note,
			CreatedAt: st.CreatedAt,
			Free:      st.Free,
			Statuses:  statuses,
		})
	}

	return res, nil
}

func (s *Service) GetGroupLessons(ctx context.Context, groupID, ownerID uuid.UUID, from, to time.Time) ([]models.LessonResponse, error) {
	logger.InfoContext(ctx, "Getting lessons for group", "group_id", groupID.String(), "user_id", ownerID.String())
	_, err := s.GetGroupByID(ctx, groupID, ownerID)
	if err != nil {
		return nil, err
	}

	rows, err := s.db.FindLessonsByGroupIDAndDateBetween(ctx, db.FindLessonsByGroupIDAndDateBetweenParams{
		GroupID: uuid.NullUUID{UUID: groupID, Valid: true},
		OwnerID: ownerID,
		Date:    from,
		Date_2:  to,
	})
	if err != nil {
		return nil, err
	}

	res := make([]models.LessonResponse, 0, len(rows))
	for _, r := range rows {
		var gID *uuid.UUID
		if r.GroupID.Valid {
			gID = &r.GroupID.UUID
		}
		res = append(res, models.LessonResponse{
			ID:        r.ID,
			Date:      r.Date,
			CreatedAt: r.CreatedAt,
			GroupID:   gID,
		})
	}
	return res, nil
}

func (s *Service) GetGroupReport(ctx context.Context, groupID, ownerID uuid.UUID, year, month int) (models.GroupReportResponse, error) {
	logger.InfoContext(ctx, "Getting group report", "group_id", groupID.String(), "year", year, "month", month, "user_id", ownerID.String())
	group, err := s.GetGroupByID(ctx, groupID, ownerID)
	if err != nil {
		return models.GroupReportResponse{}, err
	}

	firstDay := time.Date(year, time.Month(month), 1, 0, 0, 0, 0, time.UTC)
	lastDay := time.Date(year, time.Month(month)+1, 0, 23, 59, 59, 999999999, time.UTC)

	lessonRows, err := s.db.FindLessonsByGroupIDAndDateBetween(ctx, db.FindLessonsByGroupIDAndDateBetweenParams{
		GroupID: uuid.NullUUID{UUID: groupID, Valid: true},
		OwnerID: ownerID,
		Date:    firstDay,
		Date_2:  lastDay,
	})
	if err != nil {
		return models.GroupReportResponse{}, err
	}

	lessons := make([]models.LessonResponse, 0, len(lessonRows))
	lessonIDs := make([]uuid.UUID, 0, len(lessonRows))
	for _, lr := range lessonRows {
		var gID *uuid.UUID
		if lr.GroupID.Valid {
			gID = &lr.GroupID.UUID
		}
		lessons = append(lessons, models.LessonResponse{
			ID:        lr.ID,
			Date:      lr.Date,
			CreatedAt: lr.CreatedAt,
			GroupID:   gID,
		})
		lessonIDs = append(lessonIDs, lr.ID)
	}

	var lessonVisits []db.VisitsModuleVisit
	if len(lessonIDs) > 0 {
		lv, err := s.db.FindVisitsByLessonIDsAndOwnerID(ctx, db.FindVisitsByLessonIDsAndOwnerIDParams{
			OwnerID: ownerID,
			Column2: lessonIDs,
		})
		if err == nil {
			lessonVisits = lv
		}
	}

	studentLinks, _ := s.db.FindGroupStudentsByGroupIDAndOwnerID(ctx, db.FindGroupStudentsByGroupIDAndOwnerIDParams{
		GroupID: groupID,
		OwnerID: ownerID,
	})

	studentIDSet := make(map[uuid.UUID]bool)
	studentIDOrder := make([]uuid.UUID, 0)
	for _, sl := range studentLinks {
		if !studentIDSet[sl.StudentID] {
			studentIDSet[sl.StudentID] = true
			studentIDOrder = append(studentIDOrder, sl.StudentID)
		}
	}
	for _, lv := range lessonVisits {
		if !studentIDSet[lv.StudentID] {
			studentIDSet[lv.StudentID] = true
			studentIDOrder = append(studentIDOrder, lv.StudentID)
		}
	}

	visitsByStudentID := make(map[uuid.UUID][]models.VisitResponse)
	for _, sid := range studentIDOrder {
		visitsByStudentID[sid] = []models.VisitResponse{}
	}
	for _, lv := range lessonVisits {
		visitsByStudentID[lv.StudentID] = append(visitsByStudentID[lv.StudentID], models.VisitResponse{
			ID:        lv.ID,
			Status:    types.VisitStatus(lv.Status),
			Type:      types.VisitType(lv.Type),
			LessonID:  lv.LessonID,
			StudentID: lv.StudentID,
			CreatedAt: lv.CreatedAt,
		})
	}

	studentsList := make([]models.StudentResponse, 0, len(studentIDOrder))
	if len(studentIDOrder) > 0 {
		stRows, err := s.db.FindStudentsByIDsAndOwnerID(ctx, db.FindStudentsByIDsAndOwnerIDParams{
			OwnerID: ownerID,
			Column2: studentIDOrder,
		})
		if err != nil {
			return models.GroupReportResponse{}, err
		}
		stMap := make(map[uuid.UUID]models.StudentResponse)
		for _, sr := range stRows {
			var birthdate *types.Date
			if sr.Birthdate.Valid {
				birthdate = &types.Date{Time: sr.Birthdate.Time}
			}
			var phone *string
			if sr.Phone.Valid {
				phone = &sr.Phone.String
			}
			var note *string
			if sr.Note.Valid {
				note = &sr.Note.String
			}
			stMap[sr.ID] = models.StudentResponse{
				ID:        sr.ID,
				FullName:  sr.FullName,
				Birthdate: birthdate,
				Phone:     phone,
				Note:      note,
				CreatedAt: sr.CreatedAt,
				Free:      sr.Free,
			}
		}
		for _, sid := range studentIDOrder {
			if st, ok := stMap[sid]; ok {
				studentsList = append(studentsList, st)
			}
		}
	}

	pRows, err := s.db.FindStudentPaymentsByStudentIDsAndOwnerID(ctx, db.FindStudentPaymentsByStudentIDsAndOwnerIDParams{
		OwnerID: ownerID,
		Column2: studentIDOrder,
	})
	if err != nil {
		return models.GroupReportResponse{}, err
	}
	paymentsByStudentID := make(map[uuid.UUID][]models.TransactionResponse)
	for _, pr := range pRows {
		amt, _ := strconv.ParseFloat(pr.Amount, 64)
		paymentsByStudentID[pr.StudentID] = append(paymentsByStudentID[pr.StudentID], models.TransactionResponse{
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

	return BuildGroupReport(group, year, month, studentsList, lessons, visitsByStudentID, paymentsByStudentID, time.Now().UTC()), nil
}

func BuildGroupReport(group models.GroupResponse, year, month int, students []models.StudentResponse, lessons []models.LessonResponse, visitsByStudentID map[uuid.UUID][]models.VisitResponse, paymentsByStudentID map[uuid.UUID][]models.TransactionResponse, today time.Time) models.GroupReportResponse {
	lastDay := time.Date(year, time.Month(month)+1, 0, 0, 0, 0, 0, time.UTC)
	dayCount := lastDay.Day()

	lessonIDsByDay := make(map[int][]uuid.UUID)
	for _, l := range lessons {
		if l.Date.Year() == year && int(l.Date.Month()) == month {
			day := l.Date.Day()
			lessonIDsByDay[day] = append(lessonIDsByDay[day], l.ID)
		}
	}

	lessonDays := make([]int, 0, len(lessonIDsByDay))
	for day := range lessonIDsByDay {
		lessonDays = append(lessonDays, day)
	}
	sort.Ints(lessonDays)

	statusesByStudentID := make(map[uuid.UUID]map[uuid.UUID][]types.VisitStatus)
	for sid, visits := range visitsByStudentID {
		byLesson := make(map[uuid.UUID][]types.VisitStatus)
		for _, v := range visits {
			byLesson[v.LessonID] = append(byLesson[v.LessonID], v.Status)
		}
		statusesByStudentID[sid] = byLesson
	}

	sortedStudents := make([]models.StudentResponse, len(students))
	copy(sortedStudents, students)
	sort.Slice(sortedStudents, func(i, j int) bool {
		return strings.ToLower(sortedStudents[i].FullName) < strings.ToLower(sortedStudents[j].FullName)
	})

	rows := make([]models.GroupReportStudentResponse, 0, len(sortedStudents))
	totalPresent := 0
	totalLessons := 0

	for _, student := range sortedStudents {
		statusesByLessonID := statusesByStudentID[student.ID]
		presentDays := make([]int, 0)
		for _, day := range lessonDays {
			for _, lessonID := range lessonIDsByDay[day] {
				stList := statusesByLessonID[lessonID]
				isPresent := false
				for _, st := range stList {
					if st == types.VisitStatusPresent {
						isPresent = true
						break
					}
				}
				if isPresent {
					presentDays = append(presentDays, day)
					break
				}
			}
		}

		paid := isPaid(paymentsByStudentID[student.ID], year, month, today)
		pCount := len(presentDays)
		lCount := len(lessonDays)
		totalPresent += pCount
		totalLessons += lCount

		rows = append(rows, models.GroupReportStudentResponse{
			StudentID:    student.ID,
			FullName:     student.FullName,
			Paid:         paid,
			PresentDays:  presentDays,
			PresentCount: pCount,
			LessonCount:  lCount,
		})
	}

	return models.GroupReportResponse{
		GroupID:      group.ID,
		GroupName:    group.Name,
		Year:         year,
		Month:        month,
		DayCount:     dayCount,
		LessonDays:   lessonDays,
		Students:     rows,
		TotalPresent: totalPresent,
		TotalLessons: totalLessons,
	}
}

func isPaid(payments []models.TransactionResponse, year, month int, today time.Time) bool {
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
	if maxPaidUntil == nil {
		return false
	}

	todayDay := time.Date(today.Year(), today.Month(), today.Day(), 0, 0, 0, 0, time.UTC)
	firstOfMonth := time.Date(year, time.Month(month), 1, 0, 0, 0, 0, time.UTC)
	lastOfMonth := time.Date(year, time.Month(month)+1, 0, 0, 0, 0, 0, time.UTC)

	var referenceDate time.Time
	if firstOfMonth.After(todayDay) {
		referenceDate = firstOfMonth
	} else if lastOfMonth.Before(todayDay) {
		referenceDate = lastOfMonth
	} else {
		referenceDate = todayDay
	}

	paidUntilDate := time.Date(maxPaidUntil.Year(), maxPaidUntil.Month(), maxPaidUntil.Day(), 0, 0, 0, 0, time.UTC)
	return !paidUntilDate.Before(referenceDate)
}

func (s *Service) CreateGroup(ctx context.Context, req models.CreateGroupRequest, ownerID uuid.UUID) (models.GroupResponse, error) {
	logger.InfoContext(ctx, "Creating group", "name", req.Name, "user_id", ownerID.String())
	name := strings.TrimSpace(req.Name)
	if name == "" {
		return models.GroupResponse{}, &pkgerrors.BadRequestError{Message: "name must not be blank"}
	}
	if len(name) > 255 {
		return models.GroupResponse{}, &pkgerrors.BadRequestError{Message: "name must not exceed 255 characters"}
	}

	taken, err := s.db.ExistsGroupByOwnerIDAndName(ctx, db.ExistsGroupByOwnerIDAndNameParams{
		OwnerID: ownerID,
		Name:    name,
	})
	if err != nil {
		return models.GroupResponse{}, err
	}
	if taken {
		return models.GroupResponse{}, &pkgerrors.ConflictError{
			Code:    types.ErrGroupNameNotUnique,
			Message: fmt.Sprintf("A group named \"%s\" already exists", name),
		}
	}

	var uniqueStudentIDs []uuid.UUID
	if len(req.StudentIds) > 0 {
		seen := make(map[uuid.UUID]bool)
		for _, sid := range req.StudentIds {
			if !seen[sid] {
				seen[sid] = true
				uniqueStudentIDs = append(uniqueStudentIDs, sid)
			}
		}

		stRows, err := s.db.FindStudentsByIDsAndOwnerID(ctx, db.FindStudentsByIDsAndOwnerIDParams{
			OwnerID: ownerID,
			Column2: uniqueStudentIDs,
		})
		if err != nil {
			return models.GroupResponse{}, err
		}
		foundMap := make(map[uuid.UUID]bool)
		for _, sr := range stRows {
			foundMap[sr.ID] = true
		}
		unknown := make([]uuid.UUID, 0)
		for _, sid := range uniqueStudentIDs {
			if !foundMap[sid] {
				unknown = append(unknown, sid)
			}
		}
		if len(unknown) > 0 {
			return models.GroupResponse{}, &pkgerrors.BadRequestError{
				Message: fmt.Sprintf("unknown students: %v", unknown),
			}
		}
	}

	var created db.GroupsModuleGroup
	err = s.withTx(ctx, func(qtx *db.Queries) error {
		var defPrice sql.NullString
		if req.DefaultPrice != nil {
			defPrice = sql.NullString{String: strconv.FormatFloat(*req.DefaultPrice, 'f', 2, 64), Valid: true}
		}
		var note sql.NullString
		if req.Note != nil && *req.Note != "" {
			note = sql.NullString{String: *req.Note, Valid: true}
		}

		var err error
		created, err = qtx.CreateGroup(ctx, db.CreateGroupParams{
			OwnerID:      ownerID,
			Name:         name,
			DefaultPrice: defPrice,
			Note:         note,
		})
		if err != nil {
			return err
		}

		for _, sid := range uniqueStudentIDs {
			_, err := qtx.CreateGroupStudent(ctx, db.CreateGroupStudentParams{
				OwnerID:   ownerID,
				GroupID:   created.ID,
				StudentID: sid,
			})
			if err != nil {
				return err
			}
		}

		return nil
	})
	if err != nil {
		return models.GroupResponse{}, err
	}

	return toGroupResponse(created), nil
}

func (s *Service) UpdateGroup(ctx context.Context, groupID, ownerID uuid.UUID, updates map[string]interface{}) (models.GroupResponse, error) {
	logger.InfoContext(ctx, "Updating group", "group_id", groupID.String(), "user_id", ownerID.String())
	var updated db.GroupsModuleGroup

	err := s.withTx(ctx, func(qtx *db.Queries) error {
		existing, err := qtx.FindGroupByIDAndOwnerID(ctx, db.FindGroupByIDAndOwnerIDParams{
			ID:      groupID,
			OwnerID: ownerID,
		})
		if err != nil {
			if errors.Is(err, sql.ErrNoRows) {
				return &pkgerrors.NotFoundError{
					Entity:  "Group",
					ID:      groupID,
					OwnerID: ownerID,
				}
			}
			return err
		}

		name := existing.Name
		if rawName, ok := updates["name"]; ok && rawName != nil {
			nameStr, isStr := rawName.(string)
			if !isStr || strings.TrimSpace(nameStr) == "" {
				return &pkgerrors.BadRequestError{Message: "name must not be blank"}
			}
			trimmed := strings.TrimSpace(nameStr)
			if len(trimmed) > 255 {
				return &pkgerrors.BadRequestError{Message: "name must not exceed 255 characters"}
			}
			taken, err := qtx.ExistsGroupByOwnerIDAndNameAndIDNot(ctx, db.ExistsGroupByOwnerIDAndNameAndIDNotParams{
				OwnerID: ownerID,
				Name:    trimmed,
				ID:      groupID,
			})
			if err != nil {
				return err
			}
			if taken {
				return &pkgerrors.ConflictError{
					Code:    types.ErrGroupNameNotUnique,
					Message: fmt.Sprintf("A group named \"%s\" already exists", trimmed),
				}
			}
			name = trimmed
		}

		defaultPrice := existing.DefaultPrice
		if rawDP, ok := updates["defaultPrice"]; ok {
			if rawDP == nil {
				defaultPrice = sql.NullString{Valid: false}
			} else {
				switch v := rawDP.(type) {
				case float64:
					defaultPrice = sql.NullString{String: strconv.FormatFloat(v, 'f', 2, 64), Valid: true}
				case string:
					defaultPrice = sql.NullString{String: v, Valid: true}
				}
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

		if rawSIDs, ok := updates["studentIds"]; ok {
			requestedStudentIDs := parseUUIDSlice(rawSIDs)
			if len(requestedStudentIDs) > 0 {
				stRows, err := qtx.FindStudentsByIDsAndOwnerID(ctx, db.FindStudentsByIDsAndOwnerIDParams{
					OwnerID: ownerID,
					Column2: requestedStudentIDs,
				})
				if err != nil {
					return err
				}
				foundMap := make(map[uuid.UUID]bool)
				for _, sr := range stRows {
					foundMap[sr.ID] = true
				}
				unknown := make([]uuid.UUID, 0)
				for _, sid := range requestedStudentIDs {
					if !foundMap[sid] {
						unknown = append(unknown, sid)
					}
				}
				if len(unknown) > 0 {
					return &pkgerrors.BadRequestError{
						Message: fmt.Sprintf("unknown students: %v", unknown),
					}
				}
			}

			currentLinks, err := qtx.FindGroupStudentsByGroupIDAndOwnerID(ctx, db.FindGroupStudentsByGroupIDAndOwnerIDParams{
				GroupID: groupID,
				OwnerID: ownerID,
			})
			if err != nil {
				return err
			}

			reqMap := make(map[uuid.UUID]bool)
			for _, sid := range requestedStudentIDs {
				reqMap[sid] = true
			}

			for _, cl := range currentLinks {
				if !reqMap[cl.StudentID] {
					if err := qtx.DeleteGroupStudentByStudentAndGroupID(ctx, db.DeleteGroupStudentByStudentAndGroupIDParams{
						GroupID:   groupID,
						StudentID: cl.StudentID,
						OwnerID:   ownerID,
					}); err != nil {
						return err
					}
				}
			}

			curMap := make(map[uuid.UUID]bool)
			for _, cl := range currentLinks {
				curMap[cl.StudentID] = true
			}

			for _, sid := range requestedStudentIDs {
				if !curMap[sid] {
					_, err := qtx.CreateGroupStudent(ctx, db.CreateGroupStudentParams{
						OwnerID:   ownerID,
						GroupID:   groupID,
						StudentID: sid,
					})
					if err != nil {
						return err
					}
				}
			}
		}

		updated, err = qtx.UpdateGroup(ctx, db.UpdateGroupParams{
			ID:           groupID,
			OwnerID:      ownerID,
			Name:         name,
			DefaultPrice: defaultPrice,
			Note:         note,
		})
		return err
	})
	if err != nil {
		return models.GroupResponse{}, err
	}

	return toGroupResponse(updated), nil
}

func (s *Service) DeleteGroup(ctx context.Context, groupID, ownerID uuid.UUID) error {
	logger.InfoContext(ctx, "Deleting group", "group_id", groupID.String(), "user_id", ownerID.String())
	_, err := s.db.FindGroupByIDAndOwnerID(ctx, db.FindGroupByIDAndOwnerIDParams{
		ID:      groupID,
		OwnerID: ownerID,
	})
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return &pkgerrors.NotFoundError{
				Entity:  "Group",
				ID:      groupID,
				OwnerID: ownerID,
			}
		}
		return err
	}
	return s.db.DeleteGroupByIDAndOwnerID(ctx, db.DeleteGroupByIDAndOwnerIDParams{
		ID:      groupID,
		OwnerID: ownerID,
	})
}

func toGroupResponse(g db.GroupsModuleGroup) models.GroupResponse {
	var defPrice *float64
	if g.DefaultPrice.Valid {
		f, _ := strconv.ParseFloat(g.DefaultPrice.String, 64)
		defPrice = &f
	}
	var note *string
	if g.Note.Valid {
		note = &g.Note.String
	}
	return models.GroupResponse{
		ID:           g.ID,
		Name:         g.Name,
		DefaultPrice: defPrice,
		Note:         note,
		CreatedAt:    g.CreatedAt,
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
