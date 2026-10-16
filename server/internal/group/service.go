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
	pkgerrors "github.com/krivolapovdev/trenerio/pkg/errors"
	"github.com/krivolapovdev/trenerio/pkg/logger"
	"github.com/krivolapovdev/trenerio/pkg/models"
	"github.com/krivolapovdev/trenerio/pkg/types"
)

type FetchStudentsByIDsFunc func(ctx context.Context, studentIDs []uuid.UUID, ownerID uuid.UUID) ([]models.StudentResponse, error)
type ComputeStudentStatusesFunc func(student models.StudentResponse, visits []models.VisitResponse, payments []models.TransactionResponse, lessonsMap map[uuid.UUID]models.LessonResponse, groupLessonsMap map[uuid.UUID]models.LessonResponse, today time.Time) []types.StudentStatus
type FetchVisitsByStudentIDsFunc func(ctx context.Context, studentIDs []uuid.UUID, ownerID uuid.UUID) (map[uuid.UUID][]models.VisitResponse, error)
type FetchVisitsByLessonIDsFunc func(ctx context.Context, lessonIDs []uuid.UUID, ownerID uuid.UUID) ([]models.VisitResponse, error)
type FetchPaymentsByStudentIDsFunc func(ctx context.Context, studentIDs []uuid.UUID, ownerID uuid.UUID) (map[uuid.UUID][]models.TransactionResponse, error)
type FetchLessonsByGroupIDAndDateRangeFunc func(ctx context.Context, groupID, ownerID uuid.UUID, from, to time.Time) ([]models.LessonResponse, error)
type FetchLessonsByIDsFunc func(ctx context.Context, lessonIDs []uuid.UUID, ownerID uuid.UUID) ([]models.LessonResponse, error)

type Service struct {
	db                        *db.Queries
	sqlDB                     *sql.DB
	fetchStudentsByIDs        FetchStudentsByIDsFunc
	computeStudentStatuses    ComputeStudentStatusesFunc
	fetchVisitsByStudentIDs   FetchVisitsByStudentIDsFunc
	fetchVisitsByLessonIDs    FetchVisitsByLessonIDsFunc
	fetchPaymentsByStudentIDs FetchPaymentsByStudentIDsFunc
	fetchLessonsByGroup       FetchLessonsByGroupIDAndDateRangeFunc
	fetchLessonsByIDs         FetchLessonsByIDsFunc
}

func NewService(
	queries *db.Queries,
	sqlDB *sql.DB,
	fetchStudentsByIDs FetchStudentsByIDsFunc,
	computeStudentStatuses ComputeStudentStatusesFunc,
	fetchVisitsByStudentIDs FetchVisitsByStudentIDsFunc,
	fetchVisitsByLessonIDs FetchVisitsByLessonIDsFunc,
	fetchPaymentsByStudentIDs FetchPaymentsByStudentIDsFunc,
	fetchLessonsByGroup FetchLessonsByGroupIDAndDateRangeFunc,
	fetchLessonsByIDs FetchLessonsByIDsFunc,
) *Service {
	return &Service{
		db:                        queries,
		sqlDB:                     sqlDB,
		fetchStudentsByIDs:        fetchStudentsByIDs,
		computeStudentStatuses:    computeStudentStatuses,
		fetchVisitsByStudentIDs:   fetchVisitsByStudentIDs,
		fetchVisitsByLessonIDs:    fetchVisitsByLessonIDs,
		fetchPaymentsByStudentIDs: fetchPaymentsByStudentIDs,
		fetchLessonsByGroup:       fetchLessonsByGroup,
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

	stRows, err := s.fetchStudentsByIDs(ctx, studentIDs, ownerID)
	if err != nil {
		return nil, err
	}
	studentsMap := make(map[uuid.UUID]models.StudentResponse)
	for _, sr := range stRows {
		studentsMap[sr.ID] = sr
	}

	visitsByStudentID, err := s.fetchVisitsByStudentIDs(ctx, studentIDs, ownerID)
	if err != nil {
		return nil, err
	}

	allLessonIDsMap := make(map[uuid.UUID]bool)
	for _, visits := range visitsByStudentID {
		for _, vr := range visits {
			allLessonIDsMap[vr.LessonID] = true
		}
	}

	paymentsByStudentID, err := s.fetchPaymentsByStudentIDs(ctx, studentIDs, ownerID)
	if err != nil {
		return nil, err
	}

	allLessonIDs := make([]uuid.UUID, 0, len(allLessonIDsMap))
	for lid := range allLessonIDsMap {
		allLessonIDs = append(allLessonIDs, lid)
	}

	lessonsMap := make(map[uuid.UUID]models.LessonResponse)
	if len(allLessonIDs) > 0 {
		lRows, err := s.fetchLessonsByIDs(ctx, allLessonIDs, ownerID)
		if err == nil {
			for _, lr := range lRows {
				lessonsMap[lr.ID] = lr
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
		statuses := s.computeStudentStatuses(st, stVisits, stPayments, lessonsMap, groupLessonsMap, today)

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

	return s.fetchLessonsByGroup(ctx, groupID, ownerID, from, to)
}

func (s *Service) GetGroupReport(ctx context.Context, groupID, ownerID uuid.UUID, year, month int) (models.GroupReportResponse, error) {
	logger.InfoContext(ctx, "Getting group report", "group_id", groupID.String(), "year", year, "month", month, "user_id", ownerID.String())
	group, err := s.GetGroupByID(ctx, groupID, ownerID)
	if err != nil {
		return models.GroupReportResponse{}, err
	}

	firstDay := time.Date(year, time.Month(month), 1, 0, 0, 0, 0, time.UTC)
	lastDay := time.Date(year, time.Month(month)+1, 0, 23, 59, 59, 999999999, time.UTC)

	lessons, err := s.fetchLessonsByGroup(ctx, groupID, ownerID, firstDay, lastDay)
	if err != nil {
		return models.GroupReportResponse{}, err
	}

	lessonIDs := make([]uuid.UUID, 0, len(lessons))
	for _, lr := range lessons {
		lessonIDs = append(lessonIDs, lr.ID)
	}

	var lessonVisits []models.VisitResponse
	if len(lessonIDs) > 0 {
		lv, err := s.fetchVisitsByLessonIDs(ctx, lessonIDs, ownerID)
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
		visitsByStudentID[lv.StudentID] = append(visitsByStudentID[lv.StudentID], lv)
	}

	studentsList := make([]models.StudentResponse, 0, len(studentIDOrder))
	if len(studentIDOrder) > 0 {
		stRows, err := s.fetchStudentsByIDs(ctx, studentIDOrder, ownerID)
		if err != nil {
			return models.GroupReportResponse{}, err
		}
		stMap := make(map[uuid.UUID]models.StudentResponse)
		for _, sr := range stRows {
			stMap[sr.ID] = sr
		}
		for _, sid := range studentIDOrder {
			if st, ok := stMap[sid]; ok {
				studentsList = append(studentsList, st)
			}
		}
	}

	paymentsByStudentID, err := s.fetchPaymentsByStudentIDs(ctx, studentIDOrder, ownerID)
	if err != nil {
		return models.GroupReportResponse{}, err
	}

	return BuildGroupReport(group, year, month, studentsList, lessons, visitsByStudentID, paymentsByStudentID, time.Now().UTC()), nil
}

func (s *Service) GetGroupsByStudentIDs(ctx context.Context, studentIDs []uuid.UUID, ownerID uuid.UUID) (map[uuid.UUID][]models.GroupResponse, error) {
	if len(studentIDs) == 0 {
		return map[uuid.UUID][]models.GroupResponse{}, nil
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
			groupsMap[gr.ID] = toGroupResponse(gr)
		}
	}

	res := make(map[uuid.UUID][]models.GroupResponse)
	for _, sid := range studentIDs {
		gIDs := studentGroupIDsMap[sid]
		stGroups := make([]models.GroupResponse, 0, len(gIDs))
		for _, gid := range gIDs {
			if grp, ok := groupsMap[gid]; ok {
				stGroups = append(stGroups, grp)
			}
		}
		res[sid] = stGroups
	}

	return res, nil
}

func (s *Service) SetStudentGroups(ctx context.Context, studentID, ownerID uuid.UUID, groupIDs []uuid.UUID) error {
	return s.withTx(ctx, func(qtx *db.Queries) error {
		currentLinks, err := qtx.FindGroupStudentsByStudentIDAndOwnerID(ctx, db.FindGroupStudentsByStudentIDAndOwnerIDParams{
			StudentID: studentID,
			OwnerID:   ownerID,
		})
		if err != nil {
			return err
		}

		reqMap := make(map[uuid.UUID]bool)
		for _, gid := range groupIDs {
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

		for _, gid := range groupIDs {
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
	})
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

		stRows, err := s.fetchStudentsByIDs(ctx, uniqueStudentIDs, ownerID)
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
				stRows, err := s.fetchStudentsByIDs(ctx, requestedStudentIDs, ownerID)
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
