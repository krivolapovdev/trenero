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
	"github.com/krivolapovdev/trenerio/pkg/timeutil"
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
		logger.ErrorContext(ctx, "Failed to get all groups", "error", err, "user_id", ownerID.String())
		return nil, err
	}
	if len(groups) == 0 {
		logger.InfoContext(ctx, "No groups found for summary", "user_id", ownerID.String())
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
		logger.ErrorContext(ctx, "Failed to count students by group IDs", "error", err, "user_id", ownerID.String())
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

	logger.InfoContext(ctx, "Retrieved groups summary", "count", len(res), "user_id", ownerID.String())
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
			logger.WarnContext(ctx, "Group not found", "group_id", groupID.String(), "user_id", ownerID.String())
			return models.GroupResponse{}, &pkgerrors.NotFoundError{
				Entity:  "Group",
				ID:      groupID,
				OwnerID: ownerID,
			}
		}
		logger.ErrorContext(ctx, "Failed to get group by id", "group_id", groupID.String(), "error", err, "user_id", ownerID.String())
		return models.GroupResponse{}, err
	}
	logger.DebugContext(ctx, "Retrieved group by id", "group_id", groupID.String(), "user_id", ownerID.String())
	return toGroupResponse(g), nil
}

func (s *Service) GetGroupStudents(ctx context.Context, groupID, ownerID uuid.UUID) ([]models.GroupStudentSummaryResponse, error) {
	logger.InfoContext(ctx, "Getting students for group", "group_id", groupID.String(), "user_id", ownerID.String())
	_, err := s.GetGroupByID(ctx, groupID, ownerID)
	if err != nil {
		logger.WarnContext(ctx, "Group not found for getting students", "group_id", groupID.String(), "error", err, "user_id", ownerID.String())
		return nil, err
	}

	studentLinks, err := s.db.FindGroupStudentsByGroupIDAndOwnerID(ctx, db.FindGroupStudentsByGroupIDAndOwnerIDParams{
		GroupID: groupID,
		OwnerID: ownerID,
	})
	if err != nil {
		logger.ErrorContext(ctx, "Failed to fetch student links for group", "group_id", groupID.String(), "error", err, "user_id", ownerID.String())
		return nil, err
	}
	if len(studentLinks) == 0 {
		logger.InfoContext(ctx, "No students enrolled in group", "group_id", groupID.String(), "user_id", ownerID.String())
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
		logger.ErrorContext(ctx, "Failed to fetch students by IDs for group", "group_id", groupID.String(), "error", err, "user_id", ownerID.String())
		return nil, err
	}
	studentsMap := make(map[uuid.UUID]models.StudentResponse)
	for _, sr := range stRows {
		studentsMap[sr.ID] = sr
	}

	visitsByStudentID, err := s.fetchVisitsByStudentIDs(ctx, studentIDs, ownerID)
	if err != nil {
		logger.ErrorContext(ctx, "Failed to fetch visits for group students", "group_id", groupID.String(), "error", err, "user_id", ownerID.String())
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
		logger.ErrorContext(ctx, "Failed to fetch payments for group students", "group_id", groupID.String(), "error", err, "user_id", ownerID.String())
		return nil, err
	}

	allLessonIDs := make([]uuid.UUID, 0, len(allLessonIDsMap))
	for lid := range allLessonIDsMap {
		allLessonIDs = append(allLessonIDs, lid)
	}

	lessonsMap := make(map[uuid.UUID]models.LessonResponse)
	if len(allLessonIDs) > 0 {
		lRows, err := s.fetchLessonsByIDs(ctx, allLessonIDs, ownerID)
		if err != nil {
			logger.WarnContext(ctx, "Failed to fetch lessons for group students", "group_id", groupID.String(), "error", err, "user_id", ownerID.String())
		} else {
			for _, lr := range lRows {
				lessonsMap[lr.ID] = lr
			}
		}
	}

	logger.DebugContext(ctx, "Computing statuses for group students",
		"group_id", groupID.String(),
		"students_count", len(studentIDs),
		"lessons_count", len(lessonsMap),
		"user_id", ownerID.String(),
	)

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

	logger.InfoContext(ctx, "Retrieved group students", "group_id", groupID.String(), "count", len(res), "user_id", ownerID.String())
	return res, nil
}

func (s *Service) GetGroupLessons(ctx context.Context, groupID, ownerID uuid.UUID, from, to time.Time) ([]models.LessonResponse, error) {
	logger.InfoContext(ctx, "Getting lessons for group", "group_id", groupID.String(), "user_id", ownerID.String())
	_, err := s.GetGroupByID(ctx, groupID, ownerID)
	if err != nil {
		logger.WarnContext(ctx, "Group not found for getting lessons", "group_id", groupID.String(), "error", err, "user_id", ownerID.String())
		return nil, err
	}

	lessons, err := s.fetchLessonsByGroup(ctx, groupID, ownerID, from, to)
	if err != nil {
		logger.ErrorContext(ctx, "Failed to fetch lessons for group", "group_id", groupID.String(), "error", err, "user_id", ownerID.String())
		return nil, err
	}
	logger.DebugContext(ctx, "Retrieved group lessons", "group_id", groupID.String(), "count", len(lessons), "user_id", ownerID.String())
	return lessons, nil
}

func (s *Service) GetGroupReport(ctx context.Context, groupID, ownerID uuid.UUID, year, month int) (models.GroupReportResponse, error) {
	logger.InfoContext(ctx, "Getting group report", "group_id", groupID.String(), "year", year, "month", month, "user_id", ownerID.String())
	group, err := s.GetGroupByID(ctx, groupID, ownerID)
	if err != nil {
		logger.WarnContext(ctx, "Group not found for report", "group_id", groupID.String(), "user_id", ownerID.String())
		return models.GroupReportResponse{}, err
	}

	firstDay := time.Date(year, time.Month(month), 1, 0, 0, 0, 0, time.UTC)
	lastDay := time.Date(year, time.Month(month)+1, 0, 23, 59, 59, 999999999, time.UTC)

	lessons, err := s.fetchLessonsByGroup(ctx, groupID, ownerID, firstDay, lastDay)
	if err != nil {
		logger.ErrorContext(ctx, "Failed to fetch lessons for group report", "group_id", groupID.String(), "error", err, "user_id", ownerID.String())
		return models.GroupReportResponse{}, err
	}

	lessonIDs := make([]uuid.UUID, 0, len(lessons))
	for _, lr := range lessons {
		lessonIDs = append(lessonIDs, lr.ID)
	}

	var lessonVisits []models.VisitResponse
	if len(lessonIDs) > 0 {
		lv, err := s.fetchVisitsByLessonIDs(ctx, lessonIDs, ownerID)
		if err != nil {
			logger.WarnContext(ctx, "Failed to fetch visits for group report lessons", "group_id", groupID.String(), "error", err, "user_id", ownerID.String())
		} else {
			lessonVisits = lv
		}
	}

	studentLinks, err := s.db.FindGroupStudentsByGroupIDAndOwnerID(ctx, db.FindGroupStudentsByGroupIDAndOwnerIDParams{
		GroupID: groupID,
		OwnerID: ownerID,
	})
	if err != nil {
		logger.WarnContext(ctx, "Failed to fetch group student links for report", "group_id", groupID.String(), "error", err, "user_id", ownerID.String())
	}

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
			logger.ErrorContext(ctx, "Failed to fetch students for group report", "group_id", groupID.String(), "error", err, "user_id", ownerID.String())
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
		logger.ErrorContext(ctx, "Failed to fetch payments for group report", "group_id", groupID.String(), "error", err, "user_id", ownerID.String())
		return models.GroupReportResponse{}, err
	}

	logger.DebugContext(ctx, "Compiling group report data",
		"group_id", groupID.String(),
		"year", year,
		"month", month,
		"lessons_count", len(lessons),
		"students_count", len(studentsList),
		"user_id", ownerID.String(),
	)

	report := BuildGroupReport(group, year, month, studentsList, lessons, visitsByStudentID, paymentsByStudentID, time.Now().UTC())
	logger.InfoContext(ctx, "Group report generated successfully",
		"group_id", groupID.String(),
		"year", year,
		"month", month,
		"students_count", len(report.Students),
		"total_lessons", report.TotalLessons,
		"total_present", report.TotalPresent,
		"user_id", ownerID.String(),
	)
	return report, nil
}

func (s *Service) GetGroupsByStudentIDs(ctx context.Context, studentIDs []uuid.UUID, ownerID uuid.UUID) (map[uuid.UUID][]models.GroupResponse, error) {
	if len(studentIDs) == 0 {
		logger.DebugContext(ctx, "No student IDs provided to get groups", "user_id", ownerID.String())
		return map[uuid.UUID][]models.GroupResponse{}, nil
	}
	groupStudentRows, err := s.db.FindGroupStudentsByStudentIDsAndOwnerID(ctx, db.FindGroupStudentsByStudentIDsAndOwnerIDParams{
		OwnerID: ownerID,
		Column2: studentIDs,
	})
	if err != nil {
		logger.ErrorContext(ctx, "Failed to fetch student group links", "error", err, "user_id", ownerID.String())
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
			logger.ErrorContext(ctx, "Failed to fetch groups by IDs", "count", len(allGroupIDs), "error", err, "user_id", ownerID.String())
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

	logger.DebugContext(ctx, "Retrieved groups by student IDs", "student_count", len(studentIDs), "group_count", len(groupsMap), "user_id", ownerID.String())
	return res, nil
}

func (s *Service) SetStudentGroups(ctx context.Context, studentID, ownerID uuid.UUID, groupIDs []uuid.UUID) error {
	logger.InfoContext(ctx, "Setting student groups", "student_id", studentID.String(), "groups_count", len(groupIDs), "user_id", ownerID.String())
	err := s.withTx(ctx, func(qtx *db.Queries) error {
		currentLinks, err := qtx.FindGroupStudentsByStudentIDAndOwnerID(ctx, db.FindGroupStudentsByStudentIDAndOwnerIDParams{
			StudentID: studentID,
			OwnerID:   ownerID,
		})
		if err != nil {
			logger.ErrorContext(ctx, "Failed to find current student groups", "student_id", studentID.String(), "error", err, "user_id", ownerID.String())
			return err
		}

		reqMap := make(map[uuid.UUID]bool)
		for _, gid := range groupIDs {
			reqMap[gid] = true
		}

		deletedCount := 0
		for _, cl := range currentLinks {
			if !reqMap[cl.GroupID] {
				if err := qtx.DeleteGroupStudentByStudentAndGroupID(ctx, db.DeleteGroupStudentByStudentAndGroupIDParams{
					GroupID:   cl.GroupID,
					StudentID: studentID,
					OwnerID:   ownerID,
				}); err != nil {
					logger.ErrorContext(ctx, "Failed to unlink student from group", "student_id", studentID.String(), "group_id", cl.GroupID.String(), "error", err, "user_id", ownerID.String())
					return err
				}
				deletedCount++
			}
		}

		curMap := make(map[uuid.UUID]bool)
		for _, cl := range currentLinks {
			curMap[cl.GroupID] = true
		}

		createdCount := 0
		for _, gid := range groupIDs {
			if !curMap[gid] {
				_, err := qtx.CreateGroupStudent(ctx, db.CreateGroupStudentParams{
					OwnerID:   ownerID,
					GroupID:   gid,
					StudentID: studentID,
				})
				if err != nil {
					logger.ErrorContext(ctx, "Failed to link student to group", "student_id", studentID.String(), "group_id", gid.String(), "error", err, "user_id", ownerID.String())
					return err
				}
				createdCount++
			}
		}

		logger.DebugContext(ctx, "Student groups sync details", "student_id", studentID.String(), "unlinked", deletedCount, "linked", createdCount, "user_id", ownerID.String())
		return nil
	})
	if err != nil {
		logger.ErrorContext(ctx, "Failed to set student groups in database", "student_id", studentID.String(), "error", err, "user_id", ownerID.String())
		return err
	}
	logger.InfoContext(ctx, "Student groups set successfully", "student_id", studentID.String(), "groups_count", len(groupIDs), "user_id", ownerID.String())
	return nil
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

	return timeutil.IsSubscriptionActive(maxPaidUntil, referenceDate)
}

func (s *Service) CreateGroup(ctx context.Context, req models.CreateGroupRequest, ownerID uuid.UUID) (models.GroupResponse, error) {
	logger.InfoContext(ctx, "Creating group", "name", req.Name, "user_id", ownerID.String())
	name := strings.TrimSpace(req.Name)
	if name == "" {
		logger.WarnContext(ctx, "Group name must not be blank", "user_id", ownerID.String())
		return models.GroupResponse{}, &pkgerrors.BadRequestError{Message: "name must not be blank"}
	}
	if len(name) > 255 {
		logger.WarnContext(ctx, "Group name exceeds limit", "length", len(name), "user_id", ownerID.String())
		return models.GroupResponse{}, &pkgerrors.BadRequestError{Message: "name must not exceed 255 characters"}
	}

	taken, err := s.db.ExistsGroupByOwnerIDAndName(ctx, db.ExistsGroupByOwnerIDAndNameParams{
		OwnerID: ownerID,
		Name:    name,
	})
	if err != nil {
		logger.ErrorContext(ctx, "Failed to check group name uniqueness", "name", name, "error", err, "user_id", ownerID.String())
		return models.GroupResponse{}, err
	}
	if taken {
		logger.WarnContext(ctx, "Group with name already exists", "name", name, "user_id", ownerID.String())
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
			logger.ErrorContext(ctx, "Failed to fetch students by IDs for group creation", "count", len(uniqueStudentIDs), "error", err, "user_id", ownerID.String())
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
			logger.WarnContext(ctx, "Unknown student IDs provided for group creation", "unknown", unknown, "user_id", ownerID.String())
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
			logger.ErrorContext(ctx, "Failed to create group record", "name", name, "error", err, "user_id", ownerID.String())
			return err
		}

		for _, sid := range uniqueStudentIDs {
			_, err := qtx.CreateGroupStudent(ctx, db.CreateGroupStudentParams{
				OwnerID:   ownerID,
				GroupID:   created.ID,
				StudentID: sid,
			})
			if err != nil {
				logger.ErrorContext(ctx, "Failed to link student to group", "group_id", created.ID.String(), "student_id", sid.String(), "error", err, "user_id", ownerID.String())
				return err
			}
		}

		return nil
	})
	if err != nil {
		logger.ErrorContext(ctx, "Failed to create group in database", "name", name, "error", err, "user_id", ownerID.String())
		return models.GroupResponse{}, err
	}

	logger.InfoContext(ctx, "Group created successfully", "group_id", created.ID.String(), "name", created.Name, "students_count", len(uniqueStudentIDs), "user_id", ownerID.String())
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
				logger.WarnContext(ctx, "Group to update not found", "group_id", groupID.String(), "user_id", ownerID.String())
				return &pkgerrors.NotFoundError{
					Entity:  "Group",
					ID:      groupID,
					OwnerID: ownerID,
				}
			}
			logger.ErrorContext(ctx, "Failed to find group for update", "group_id", groupID.String(), "error", err, "user_id", ownerID.String())
			return err
		}

		name := existing.Name
		if rawName, ok := updates["name"]; ok && rawName != nil {
			nameStr, isStr := rawName.(string)
			if !isStr || strings.TrimSpace(nameStr) == "" {
				logger.WarnContext(ctx, "Updated group name must not be blank", "group_id", groupID.String(), "user_id", ownerID.String())
				return &pkgerrors.BadRequestError{Message: "name must not be blank"}
			}
			trimmed := strings.TrimSpace(nameStr)
			if len(trimmed) > 255 {
				logger.WarnContext(ctx, "Updated group name exceeds limit", "length", len(trimmed), "group_id", groupID.String(), "user_id", ownerID.String())
				return &pkgerrors.BadRequestError{Message: "name must not exceed 255 characters"}
			}
			taken, err := qtx.ExistsGroupByOwnerIDAndNameAndIDNot(ctx, db.ExistsGroupByOwnerIDAndNameAndIDNotParams{
				OwnerID: ownerID,
				Name:    trimmed,
				ID:      groupID,
			})
			if err != nil {
				logger.ErrorContext(ctx, "Failed to check group name uniqueness for update", "name", trimmed, "group_id", groupID.String(), "error", err, "user_id", ownerID.String())
				return err
			}
			if taken {
				logger.WarnContext(ctx, "Group name already exists for update", "name", trimmed, "group_id", groupID.String(), "user_id", ownerID.String())
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
					logger.ErrorContext(ctx, "Failed to fetch students by IDs for group update", "count", len(requestedStudentIDs), "error", err, "user_id", ownerID.String())
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
					logger.WarnContext(ctx, "Unknown students provided for group update", "group_id", groupID.String(), "unknown", unknown, "user_id", ownerID.String())
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
				logger.ErrorContext(ctx, "Failed to find current group students for update", "group_id", groupID.String(), "error", err, "user_id", ownerID.String())
				return err
			}

			reqMap := make(map[uuid.UUID]bool)
			for _, sid := range requestedStudentIDs {
				reqMap[sid] = true
			}

			deletedCount := 0
			for _, cl := range currentLinks {
				if !reqMap[cl.StudentID] {
					if err := qtx.DeleteGroupStudentByStudentAndGroupID(ctx, db.DeleteGroupStudentByStudentAndGroupIDParams{
						GroupID:   groupID,
						StudentID: cl.StudentID,
						OwnerID:   ownerID,
					}); err != nil {
						logger.ErrorContext(ctx, "Failed to unlink student during group update", "group_id", groupID.String(), "student_id", cl.StudentID.String(), "error", err, "user_id", ownerID.String())
						return err
					}
					deletedCount++
				}
			}

			curMap := make(map[uuid.UUID]bool)
			for _, cl := range currentLinks {
				curMap[cl.StudentID] = true
			}

			createdCount := 0
			for _, sid := range requestedStudentIDs {
				if !curMap[sid] {
					_, err := qtx.CreateGroupStudent(ctx, db.CreateGroupStudentParams{
						OwnerID:   ownerID,
						GroupID:   groupID,
						StudentID: sid,
					})
					if err != nil {
						logger.ErrorContext(ctx, "Failed to link student during group update", "group_id", groupID.String(), "student_id", sid.String(), "error", err, "user_id", ownerID.String())
						return err
					}
					createdCount++
				}
			}

			logger.DebugContext(ctx, "Group students synced during update", "group_id", groupID.String(), "unlinked", deletedCount, "linked", createdCount, "user_id", ownerID.String())
		}

		updated, err = qtx.UpdateGroup(ctx, db.UpdateGroupParams{
			ID:           groupID,
			OwnerID:      ownerID,
			Name:         name,
			DefaultPrice: defaultPrice,
			Note:         note,
		})
		if err != nil {
			logger.ErrorContext(ctx, "Failed to update group record", "group_id", groupID.String(), "error", err, "user_id", ownerID.String())
			return err
		}
		return nil
	})
	if err != nil {
		logger.ErrorContext(ctx, "Failed to update group in database", "group_id", groupID.String(), "error", err, "user_id", ownerID.String())
		return models.GroupResponse{}, err
	}

	logger.InfoContext(ctx, "Group updated successfully", "group_id", updated.ID.String(), "name", updated.Name, "user_id", ownerID.String())
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
			logger.WarnContext(ctx, "Group to delete not found", "group_id", groupID.String(), "user_id", ownerID.String())
			return &pkgerrors.NotFoundError{
				Entity:  "Group",
				ID:      groupID,
				OwnerID: ownerID,
			}
		}
		logger.ErrorContext(ctx, "Failed to find group for deletion", "group_id", groupID.String(), "error", err, "user_id", ownerID.String())
		return err
	}
	if err := s.db.DeleteGroupByIDAndOwnerID(ctx, db.DeleteGroupByIDAndOwnerIDParams{
		ID:      groupID,
		OwnerID: ownerID,
	}); err != nil {
		logger.ErrorContext(ctx, "Failed to delete group record", "group_id", groupID.String(), "error", err, "user_id", ownerID.String())
		return err
	}
	logger.InfoContext(ctx, "Group deleted successfully", "group_id", groupID.String(), "user_id", ownerID.String())
	return nil
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
