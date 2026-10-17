package group

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
	"github.com/krivolapovdev/trenerio/pkg/utils"
	"golang.org/x/sync/errgroup"
)

type FetchStudentsByIDsFunc func(ctx context.Context, studentIDs []uuid.UUID, ownerID uuid.UUID) ([]models.StudentResponse, error)
type ComputeStudentStatusesFunc func(st models.StudentResponse, visits []models.VisitResponse, payments []models.TransactionResponse, lessonsMap map[uuid.UUID]models.LessonResponse, groupLessonsMap map[uuid.UUID]models.LessonResponse, today time.Time) []types.StudentStatus
type FetchVisitsByStudentIDsFunc func(ctx context.Context, studentIDs []uuid.UUID, ownerID uuid.UUID) (map[uuid.UUID][]models.VisitResponse, error)
type FetchVisitsByLessonIDsFunc func(ctx context.Context, lessonIDs []uuid.UUID, ownerID uuid.UUID) ([]models.VisitResponse, error)
type FetchPaymentsByStudentIDsFunc func(ctx context.Context, studentIDs []uuid.UUID, ownerID uuid.UUID) (map[uuid.UUID][]models.TransactionResponse, error)
type FetchLessonsByGroupIDAndDateRangeFunc func(ctx context.Context, groupID, ownerID uuid.UUID, from, to time.Time) ([]models.LessonResponse, error)
type FetchLessonsByIDsFunc func(ctx context.Context, lessonIDs []uuid.UUID, ownerID uuid.UUID) ([]models.LessonResponse, error)

type Service interface {
	GetAllGroupsSummary(ctx context.Context, ownerID uuid.UUID) ([]models.GroupSummaryResponse, error)
	GetGroupByID(ctx context.Context, groupID, ownerID uuid.UUID) (models.GroupResponse, error)
	GetGroupStudents(ctx context.Context, groupID, ownerID uuid.UUID) ([]models.GroupStudentSummaryResponse, error)
	GetGroupLessons(ctx context.Context, groupID, ownerID uuid.UUID, from, to time.Time) ([]models.LessonResponse, error)
	GetGroupReport(ctx context.Context, groupID, ownerID uuid.UUID, year, month int) (models.GroupReportResponse, error)
	GetGroupsByStudentIDs(ctx context.Context, studentIDs []uuid.UUID, ownerID uuid.UUID) (map[uuid.UUID][]models.GroupResponse, error)
	SetStudentGroups(ctx context.Context, studentID, ownerID uuid.UUID, groupIDs []uuid.UUID) error
	CreateGroup(ctx context.Context, req models.CreateGroupRequest, ownerID uuid.UUID) (models.GroupResponse, error)
	UpdateGroup(ctx context.Context, groupID, ownerID uuid.UUID, updates map[string]any) (models.GroupResponse, error)
	DeleteGroup(ctx context.Context, groupID, ownerID uuid.UUID) error
}

type service struct {
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
) Service {
	return &service{
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

func (s *service) withTx(ctx context.Context, fn func(qtx *db.Queries) error) error {
	return db.WithTx(ctx, s.sqlDB, s.db, fn)
}

func (s *service) GetAllGroupsSummary(ctx context.Context, ownerID uuid.UUID) ([]models.GroupSummaryResponse, error) {
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

	countMap := make(map[uuid.UUID]int64, len(counts))
	for _, c := range counts {
		countMap[c.GroupID] = c.StudentCount
	}

	summaries := make([]models.GroupSummaryResponse, 0, len(groups))
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
		summaries = append(summaries, models.GroupSummaryResponse{
			ID:              g.ID,
			Name:            g.Name,
			DefaultPrice:    defPrice,
			Note:            note,
			CreatedAt:       g.CreatedAt,
			CountOfStudents: countMap[g.ID],
		})
	}

	logger.InfoContext(ctx, "Retrieved groups summary", "count", len(summaries), "user_id", ownerID.String())
	return summaries, nil
}

func (s *service) GetGroupByID(ctx context.Context, groupID, ownerID uuid.UUID) (models.GroupResponse, error) {
	logger.InfoContext(ctx, "Getting group by id", "group_id", groupID.String(), "user_id", ownerID.String())
	g, err := s.db.FindGroupByIDAndOwnerID(ctx, db.FindGroupByIDAndOwnerIDParams{
		ID:      groupID,
		OwnerID: ownerID,
	})
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			logger.WarnContext(ctx, "Group not found", "group_id", groupID.String(), "user_id", ownerID.String())
			return models.GroupResponse{}, pkgerrors.NewNotFound("Group", groupID, ownerID)
		}
		logger.ErrorContext(ctx, "Failed to get group by id", "group_id", groupID.String(), "error", err, "user_id", ownerID.String())
		return models.GroupResponse{}, err
	}
	logger.DebugContext(ctx, "Retrieved group by id", "group_id", groupID.String(), "user_id", ownerID.String())
	return toGroupResponse(g), nil
}

func (s *service) GetGroupStudents(ctx context.Context, groupID, ownerID uuid.UUID) ([]models.GroupStudentSummaryResponse, error) {
	logger.InfoContext(ctx, "Getting students for group", "group_id", groupID.String(), "user_id", ownerID.String())
	if _, err := s.GetGroupByID(ctx, groupID, ownerID); err != nil {
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
	for _, sl := range studentLinks {
		studentIDs = append(studentIDs, sl.StudentID)
	}
	studentIDs = utils.UniqueUUIDs(studentIDs)

	var (
		stRows              []models.StudentResponse
		visitsByStudentID   map[uuid.UUID][]models.VisitResponse
		paymentsByStudentID map[uuid.UUID][]models.TransactionResponse
	)

	g, gCtx := errgroup.WithContext(ctx)
	if s.fetchStudentsByIDs != nil {
		g.Go(func() error {
			rows, err := s.fetchStudentsByIDs(gCtx, studentIDs, ownerID)
			if err != nil {
				return err
			}
			stRows = rows
			return nil
		})
	}
	if s.fetchVisitsByStudentIDs != nil {
		g.Go(func() error {
			vm, err := s.fetchVisitsByStudentIDs(gCtx, studentIDs, ownerID)
			if err != nil {
				return err
			}
			visitsByStudentID = vm
			return nil
		})
	}
	if s.fetchPaymentsByStudentIDs != nil {
		g.Go(func() error {
			pm, err := s.fetchPaymentsByStudentIDs(gCtx, studentIDs, ownerID)
			if err != nil {
				return err
			}
			paymentsByStudentID = pm
			return nil
		})
	}

	if err := g.Wait(); err != nil {
		logger.ErrorContext(ctx, "Failed to fetch group student dependencies concurrently", "group_id", groupID.String(), "error", err, "user_id", ownerID.String())
		return nil, err
	}

	studentsMap := make(map[uuid.UUID]models.StudentResponse, len(stRows))
	for _, sr := range stRows {
		studentsMap[sr.ID] = sr
	}

	allLessonIDsMap := make(map[uuid.UUID]bool)
	for _, visits := range visitsByStudentID {
		for _, vr := range visits {
			allLessonIDsMap[vr.LessonID] = true
		}
	}

	allLessonIDs := make([]uuid.UUID, 0, len(allLessonIDsMap))
	for lid := range allLessonIDsMap {
		allLessonIDs = append(allLessonIDs, lid)
	}

	lessonsMap := make(map[uuid.UUID]models.LessonResponse, len(allLessonIDs))
	if len(allLessonIDs) > 0 && s.fetchLessonsByIDs != nil {
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
	groupStudents := make([]models.GroupStudentSummaryResponse, 0, len(studentIDs))
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

		var statuses []types.StudentStatus
		if s.computeStudentStatuses != nil {
			statuses = s.computeStudentStatuses(st, stVisits, stPayments, lessonsMap, groupLessonsMap, today)
		}

		groupStudents = append(groupStudents, models.GroupStudentSummaryResponse{
			ID:        st.ID,
			FullName:  st.FullName,
			Birthdate: st.Birthdate,
			Phone:     phonePtr(st.Phone),
			Note:      st.Note,
			CreatedAt: st.CreatedAt,
			Free:      st.Free,
			Statuses:  statuses,
		})
	}

	logger.InfoContext(ctx, "Retrieved group students", "group_id", groupID.String(), "count", len(groupStudents), "user_id", ownerID.String())
	return groupStudents, nil
}

func phonePtr(p *string) *string {
	if p == nil || *p == "" {
		return nil
	}
	return p
}

func (s *service) GetGroupLessons(ctx context.Context, groupID, ownerID uuid.UUID, from, to time.Time) ([]models.LessonResponse, error) {
	logger.InfoContext(ctx, "Getting lessons for group", "group_id", groupID.String(), "user_id", ownerID.String())
	if _, err := s.GetGroupByID(ctx, groupID, ownerID); err != nil {
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

func (s *service) GetGroupReport(ctx context.Context, groupID, ownerID uuid.UUID, year, month int) (models.GroupReportResponse, error) {
	logger.InfoContext(ctx, "Getting group report", "group_id", groupID.String(), "year", year, "month", month, "user_id", ownerID.String())
	grp, err := s.GetGroupByID(ctx, groupID, ownerID)
	if err != nil {
		logger.WarnContext(ctx, "Group not found for report", "group_id", groupID.String(), "user_id", ownerID.String())
		return models.GroupReportResponse{}, err
	}

	firstDay := time.Date(year, time.Month(month), 1, 0, 0, 0, 0, time.UTC)
	lastDay := time.Date(year, time.Month(month)+1, 0, 23, 59, 59, 999999999, time.UTC)

	var (
		lessons      []models.LessonResponse
		studentLinks []db.GroupsModuleGroupStudent
	)

	g, gCtx := errgroup.WithContext(ctx)
	if s.fetchLessonsByGroup != nil {
		g.Go(func() error {
			lList, err := s.fetchLessonsByGroup(gCtx, groupID, ownerID, firstDay, lastDay)
			if err != nil {
				return err
			}
			lessons = lList
			return nil
		})
	}
	g.Go(func() error {
		sl, err := s.db.FindGroupStudentsByGroupIDAndOwnerID(gCtx, db.FindGroupStudentsByGroupIDAndOwnerIDParams{
			GroupID: groupID,
			OwnerID: ownerID,
		})
		if err != nil {
			logger.WarnContext(gCtx, "Failed to fetch group student links for report", "group_id", groupID.String(), "error", err, "user_id", ownerID.String())
		} else {
			studentLinks = sl
		}
		return nil
	})

	if err := g.Wait(); err != nil {
		logger.ErrorContext(ctx, "Failed to fetch group report base dependencies", "group_id", groupID.String(), "error", err, "user_id", ownerID.String())
		return models.GroupReportResponse{}, err
	}

	lessonIDs := make([]uuid.UUID, 0, len(lessons))
	for _, lr := range lessons {
		lessonIDs = append(lessonIDs, lr.ID)
	}

	var lessonVisits []models.VisitResponse
	if len(lessonIDs) > 0 && s.fetchVisitsByLessonIDs != nil {
		lv, err := s.fetchVisitsByLessonIDs(ctx, lessonIDs, ownerID)
		if err != nil {
			logger.WarnContext(ctx, "Failed to fetch visits for group report lessons", "group_id", groupID.String(), "error", err, "user_id", ownerID.String())
		} else {
			lessonVisits = lv
		}
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

	visitsByStudentID := make(map[uuid.UUID][]models.VisitResponse, len(studentIDOrder))
	for _, sid := range studentIDOrder {
		visitsByStudentID[sid] = []models.VisitResponse{}
	}
	for _, lv := range lessonVisits {
		visitsByStudentID[lv.StudentID] = append(visitsByStudentID[lv.StudentID], lv)
	}

	var (
		studentsList        []models.StudentResponse
		paymentsByStudentID map[uuid.UUID][]models.TransactionResponse
	)

	if len(studentIDOrder) > 0 {
		g2, g2Ctx := errgroup.WithContext(ctx)
		if s.fetchStudentsByIDs != nil {
			g2.Go(func() error {
				stRows, err := s.fetchStudentsByIDs(g2Ctx, studentIDOrder, ownerID)
				if err != nil {
					return err
				}
				stMap := make(map[uuid.UUID]models.StudentResponse, len(stRows))
				for _, sr := range stRows {
					stMap[sr.ID] = sr
				}
				studentsList = make([]models.StudentResponse, 0, len(studentIDOrder))
				for _, sid := range studentIDOrder {
					if st, ok := stMap[sid]; ok {
						studentsList = append(studentsList, st)
					}
				}
				return nil
			})
		}
		if s.fetchPaymentsByStudentIDs != nil {
			g2.Go(func() error {
				pm, err := s.fetchPaymentsByStudentIDs(g2Ctx, studentIDOrder, ownerID)
				if err != nil {
					return err
				}
				paymentsByStudentID = pm
				return nil
			})
		}
		if err := g2.Wait(); err != nil {
			logger.ErrorContext(ctx, "Failed to fetch students or payments for group report", "group_id", groupID.String(), "error", err, "user_id", ownerID.String())
			return models.GroupReportResponse{}, err
		}
	}

	logger.DebugContext(ctx, "Compiling group report data",
		"group_id", groupID.String(),
		"year", year,
		"month", month,
		"lessons_count", len(lessons),
		"students_count", len(studentsList),
		"user_id", ownerID.String(),
	)

	report := BuildGroupReport(grp, year, month, studentsList, lessons, visitsByStudentID, paymentsByStudentID, time.Now().UTC())
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

func (s *service) GetGroupsByStudentIDs(ctx context.Context, studentIDs []uuid.UUID, ownerID uuid.UUID) (map[uuid.UUID][]models.GroupResponse, error) {
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

	groupsMap := make(map[uuid.UUID]models.GroupResponse, len(allGroupIDs))
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

	groupsByStudent := make(map[uuid.UUID][]models.GroupResponse, len(studentIDs))
	for _, sid := range studentIDs {
		gIDs := studentGroupIDsMap[sid]
		stGroups := make([]models.GroupResponse, 0, len(gIDs))
		for _, gid := range gIDs {
			if grp, ok := groupsMap[gid]; ok {
				stGroups = append(stGroups, grp)
			}
		}
		groupsByStudent[sid] = stGroups
	}

	logger.DebugContext(ctx, "Retrieved groups by student IDs", "student_count", len(studentIDs), "group_count", len(groupsMap), "user_id", ownerID.String())
	return groupsByStudent, nil
}

func (s *service) SetStudentGroups(ctx context.Context, studentID, ownerID uuid.UUID, groupIDs []uuid.UUID) error {
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

		currentGroupIDs := make([]uuid.UUID, 0, len(currentLinks))
		for _, cl := range currentLinks {
			currentGroupIDs = append(currentGroupIDs, cl.GroupID)
		}

		toDelete, toCreate := utils.DiffUUIDs(currentGroupIDs, groupIDs)

		for _, gid := range toDelete {
			if err := qtx.DeleteGroupStudentByStudentAndGroupID(ctx, db.DeleteGroupStudentByStudentAndGroupIDParams{
				GroupID:   gid,
				StudentID: studentID,
				OwnerID:   ownerID,
			}); err != nil {
				logger.ErrorContext(ctx, "Failed to unlink student from group", "student_id", studentID.String(), "group_id", gid.String(), "error", err, "user_id", ownerID.String())
				return err
			}
		}

		for _, gid := range toCreate {
			_, err := qtx.CreateGroupStudent(ctx, db.CreateGroupStudentParams{
				OwnerID:   ownerID,
				GroupID:   gid,
				StudentID: studentID,
			})
			if err != nil {
				logger.ErrorContext(ctx, "Failed to link student to group", "student_id", studentID.String(), "group_id", gid.String(), "error", err, "user_id", ownerID.String())
				return err
			}
		}

		logger.DebugContext(ctx, "Student groups sync details", "student_id", studentID.String(), "unlinked", len(toDelete), "linked", len(toCreate), "user_id", ownerID.String())
		return nil
	})
	if err != nil {
		logger.ErrorContext(ctx, "Failed to set student groups in database", "student_id", studentID.String(), "error", err, "user_id", ownerID.String())
		return err
	}
	logger.InfoContext(ctx, "Student groups set successfully", "student_id", studentID.String(), "groups_count", len(groupIDs), "user_id", ownerID.String())
	return nil
}

func (s *service) CreateGroup(ctx context.Context, req models.CreateGroupRequest, ownerID uuid.UUID) (models.GroupResponse, error) {
	logger.InfoContext(ctx, "Creating group", "name", req.Name, "user_id", ownerID.String())
	name, err := utils.ValidateRequiredName(req.Name, "name")
	if err != nil {
		logger.WarnContext(ctx, "Group name validation failed", "user_id", ownerID.String())
		return models.GroupResponse{}, err
	}

	if req.DefaultPrice != nil && *req.DefaultPrice <= 0 {
		logger.WarnContext(ctx, "Group default price must be greater than 0", "default_price", *req.DefaultPrice, "user_id", ownerID.String())
		return models.GroupResponse{}, pkgerrors.NewBadRequest("defaultPrice must be greater than 0")
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
		return models.GroupResponse{}, pkgerrors.NewConflict(
			types.ErrGroupNameNotUnique,
			fmt.Sprintf("A group named \"%s\" already exists", name),
		)
	}

	var uniqueStudentIDs []uuid.UUID
	if len(req.StudentIds) > 0 && s.fetchStudentsByIDs != nil {
		uniqueStudentIDs = utils.UniqueUUIDs(req.StudentIds)
		if err := validateStudentIDsExist(ctx, s.fetchStudentsByIDs, uniqueStudentIDs, ownerID, "group creation"); err != nil {
			return models.GroupResponse{}, err
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

func (s *service) UpdateGroup(ctx context.Context, groupID, ownerID uuid.UUID, updates map[string]any) (models.GroupResponse, error) {
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
				return pkgerrors.NewNotFound("Group", groupID, ownerID)
			}
			logger.ErrorContext(ctx, "Failed to find group for update", "group_id", groupID.String(), "error", err, "user_id", ownerID.String())
			return err
		}

		name := existing.Name
		if rawName, ok := updates["name"]; ok && rawName != nil {
			nameStr, isStr := rawName.(string)
			if !isStr {
				logger.WarnContext(ctx, "Updated group name must not be blank", "group_id", groupID.String(), "user_id", ownerID.String())
				return pkgerrors.NewBadRequest("name must not be blank")
			}
			trimmed, err := utils.ValidateRequiredName(nameStr, "name")
			if err != nil {
				logger.WarnContext(ctx, "Updated group name validation failed", "group_id", groupID.String(), "user_id", ownerID.String())
				return err
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
				return pkgerrors.NewConflict(
					types.ErrGroupNameNotUnique,
					fmt.Sprintf("A group named \"%s\" already exists", trimmed),
				)
			}
			name = trimmed
		}

		defaultPrice := existing.DefaultPrice
		if rawDP, ok := updates["defaultPrice"]; ok {
			if rawDP == nil {
				defaultPrice = sql.NullString{Valid: false}
			} else {
				var priceVal float64
				switch v := rawDP.(type) {
				case float64:
					priceVal = v
				case int:
					priceVal = float64(v)
				case int64:
					priceVal = float64(v)
				case string:
					p, err := strconv.ParseFloat(v, 64)
					if err != nil {
						logger.WarnContext(ctx, "Invalid defaultPrice format for update", "group_id", groupID.String(), "user_id", ownerID.String())
						return pkgerrors.NewBadRequest("invalid defaultPrice format")
					}
					priceVal = p
				default:
					logger.WarnContext(ctx, "Invalid defaultPrice type for update", "group_id", groupID.String(), "user_id", ownerID.String())
					return pkgerrors.NewBadRequest("invalid defaultPrice format")
				}
				if priceVal <= 0 {
					logger.WarnContext(ctx, "Group default price must be greater than 0 for update", "group_id", groupID.String(), "user_id", ownerID.String())
					return pkgerrors.NewBadRequest("defaultPrice must be greater than 0")
				}
				defaultPrice = sql.NullString{String: strconv.FormatFloat(priceVal, 'f', 2, 64), Valid: true}
			}
		}

		note := existing.Note
		if rawNote, ok := updates["note"]; ok {
			if rawNote == nil {
				note = sql.NullString{Valid: false}
			} else if str, ok := rawNote.(string); ok {
				note = sql.NullString{String: str, Valid: true}
			}
		}

		if rawSIDs, ok := updates["studentIds"]; ok && s.fetchStudentsByIDs != nil {
			requestedStudentIDs := types.ParseUUIDSlice(rawSIDs)
			if len(requestedStudentIDs) > 0 {
				if err := validateStudentIDsExist(ctx, s.fetchStudentsByIDs, requestedStudentIDs, ownerID, "group update"); err != nil {
					return err
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

			currentStudentIDs := make([]uuid.UUID, 0, len(currentLinks))
			for _, cl := range currentLinks {
				currentStudentIDs = append(currentStudentIDs, cl.StudentID)
			}

			toDelete, toCreate := utils.DiffUUIDs(currentStudentIDs, requestedStudentIDs)
			deletedCount := 0
			for _, sid := range toDelete {
				if err := qtx.DeleteGroupStudentByStudentAndGroupID(ctx, db.DeleteGroupStudentByStudentAndGroupIDParams{
					GroupID:   groupID,
					StudentID: sid,
					OwnerID:   ownerID,
				}); err != nil {
					logger.ErrorContext(ctx, "Failed to unlink student during group update", "group_id", groupID.String(), "student_id", sid.String(), "error", err, "user_id", ownerID.String())
					return err
				}
				deletedCount++
			}

			createdCount := 0
			for _, sid := range toCreate {
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

func (s *service) DeleteGroup(ctx context.Context, groupID, ownerID uuid.UUID) error {
	logger.InfoContext(ctx, "Deleting group", "group_id", groupID.String(), "user_id", ownerID.String())
	_, err := s.db.FindGroupByIDAndOwnerID(ctx, db.FindGroupByIDAndOwnerIDParams{
		ID:      groupID,
		OwnerID: ownerID,
	})
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			logger.WarnContext(ctx, "Group to delete not found", "group_id", groupID.String(), "user_id", ownerID.String())
			return pkgerrors.NewNotFound("Group", groupID, ownerID)
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
