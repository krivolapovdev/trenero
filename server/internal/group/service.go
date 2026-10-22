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
	pkgerrors "github.com/krivolapovdev/trenerio/internal/shared/errors"
	"github.com/krivolapovdev/trenerio/internal/shared/logger"
	"github.com/krivolapovdev/trenerio/internal/shared/request"
	"github.com/krivolapovdev/trenerio/internal/shared/response"
	"github.com/krivolapovdev/trenerio/internal/shared/types"
	"github.com/krivolapovdev/trenerio/internal/shared/utils"
	"github.com/krivolapovdev/trenerio/internal/shared/validator"
	"github.com/krivolapovdev/trenerio/internal/student"
	"github.com/krivolapovdev/trenerio/internal/transaction"
	"github.com/krivolapovdev/trenerio/internal/visit"
	"golang.org/x/sync/errgroup"
)

type StudentProvider interface {
	GetStudentsByIDs(ctx context.Context, studentIDs []uuid.UUID, ownerID uuid.UUID) ([]response.StudentResponse, error)
	ComputeStudentStatuses(st response.StudentResponse, visits []visit.VisitResponse, payments []transaction.TransactionResponse, lessonsMap map[uuid.UUID]response.LessonResponse, groupLessonsMap map[uuid.UUID]response.LessonResponse, today time.Time) []student.StudentStatus
}

type VisitProvider interface {
	GetVisitsByStudentIDs(ctx context.Context, studentIDs []uuid.UUID, ownerID uuid.UUID) (map[uuid.UUID][]visit.VisitResponse, error)
	GetVisitsByLessonIDs(ctx context.Context, lessonIDs []uuid.UUID, ownerID uuid.UUID) ([]visit.VisitResponse, error)
}

type TransactionProvider interface {
	GetTransactionsByStudentIDs(ctx context.Context, studentIDs []uuid.UUID, ownerID uuid.UUID) (map[uuid.UUID][]transaction.TransactionResponse, error)
}

type LessonProvider interface {
	GetLessonsByGroupIDAndDateRange(ctx context.Context, groupID, ownerID uuid.UUID, from, to time.Time) ([]response.LessonResponse, error)
	GetLessonsByIDs(ctx context.Context, lessonIDs []uuid.UUID, ownerID uuid.UUID) ([]response.LessonResponse, error)
}

type Service struct {
	db                  *db.Queries
	sqlDB               *sql.DB
	studentProvider     StudentProvider
	visitProvider       VisitProvider
	transactionProvider TransactionProvider
	lessonProvider      LessonProvider
}

func NewService(
	queries *db.Queries,
	sqlDB *sql.DB,
	studentProvider StudentProvider,
	visitProvider VisitProvider,
	transactionProvider TransactionProvider,
	lessonProvider LessonProvider,
) *Service {
	return &Service{
		db:                  queries,
		sqlDB:               sqlDB,
		studentProvider:     studentProvider,
		visitProvider:       visitProvider,
		transactionProvider: transactionProvider,
		lessonProvider:      lessonProvider,
	}
}

func (s *Service) withTx(ctx context.Context, fn func(qtx *db.Queries) error) error {
	if s.sqlDB == nil {
		return fn(s.db)
	}
	return db.WithTx(ctx, s.sqlDB, s.db, fn)
}

func (s *Service) GetAllGroupsSummary(ctx context.Context, ownerID uuid.UUID) ([]response.GroupSummaryResponse, error) {
	logger.InfoContext(ctx, "Getting all groups summary", "user_id", ownerID.String())
	groups, err := s.db.FindAllGroupsByOwnerID(ctx, ownerID)
	if err != nil {
		logger.ErrorContext(ctx, "Failed to get all groups", "error", err, "user_id", ownerID.String())
		return nil, err
	}
	if len(groups) == 0 {
		logger.InfoContext(ctx, "No groups found for summary", "user_id", ownerID.String())
		return []response.GroupSummaryResponse{}, nil
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

	summaries := make([]response.GroupSummaryResponse, 0, len(groups))
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
		summaries = append(summaries, response.GroupSummaryResponse{
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

func (s *Service) GetGroupByID(ctx context.Context, groupID, ownerID uuid.UUID) (response.GroupResponse, error) {
	logger.InfoContext(ctx, "Getting group by id", "group_id", groupID.String(), "user_id", ownerID.String())
	g, err := s.db.FindGroupByIDAndOwnerID(ctx, db.FindGroupByIDAndOwnerIDParams{
		ID:      groupID,
		OwnerID: ownerID,
	})
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			logger.WarnContext(ctx, "Group not found", "group_id", groupID.String(), "user_id", ownerID.String())
			return response.GroupResponse{}, pkgerrors.NewNotFound("Group", groupID, ownerID)
		}
		logger.ErrorContext(ctx, "Failed to get group by id", "group_id", groupID.String(), "error", err, "user_id", ownerID.String())
		return response.GroupResponse{}, err
	}
	logger.DebugContext(ctx, "Retrieved group by id", "group_id", groupID.String(), "user_id", ownerID.String())
	return toGroupResponse(g), nil
}

func (s *Service) GetGroupStudents(ctx context.Context, groupID, ownerID uuid.UUID) ([]GroupStudentSummaryResponse, error) {
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
		return []GroupStudentSummaryResponse{}, nil
	}

	studentIDs := make([]uuid.UUID, 0, len(studentLinks))
	for _, sl := range studentLinks {
		studentIDs = append(studentIDs, sl.StudentID)
	}
	studentIDs = utils.UniqueUUIDs(studentIDs)

	var (
		stRows              []response.StudentResponse
		visitsByStudentID   map[uuid.UUID][]visit.VisitResponse
		paymentsByStudentID map[uuid.UUID][]transaction.TransactionResponse
	)

	g, gCtx := errgroup.WithContext(ctx)
	if s.studentProvider != nil {
		g.Go(func() error {
			rows, err := s.studentProvider.GetStudentsByIDs(gCtx, studentIDs, ownerID)
			if err != nil {
				return err
			}
			stRows = rows
			return nil
		})
	}
	if s.visitProvider != nil {
		g.Go(func() error {
			vm, err := s.visitProvider.GetVisitsByStudentIDs(gCtx, studentIDs, ownerID)
			if err != nil {
				return err
			}
			visitsByStudentID = vm
			return nil
		})
	}
	if s.transactionProvider != nil {
		g.Go(func() error {
			pm, err := s.transactionProvider.GetTransactionsByStudentIDs(gCtx, studentIDs, ownerID)
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

	studentsMap := make(map[uuid.UUID]response.StudentResponse, len(stRows))
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

	lessonsMap := make(map[uuid.UUID]response.LessonResponse, len(allLessonIDs))
	if len(allLessonIDs) > 0 && s.lessonProvider != nil {
		lRows, err := s.lessonProvider.GetLessonsByIDs(ctx, allLessonIDs, ownerID)
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
	groupStudents := make([]GroupStudentSummaryResponse, 0, len(studentIDs))
	for _, sid := range studentIDs {
		st, ok := studentsMap[sid]
		if !ok {
			continue
		}
		stVisits := visitsByStudentID[sid]
		stPayments := paymentsByStudentID[sid]
		groupLessonsMap := make(map[uuid.UUID]response.LessonResponse)
		for lid, l := range lessonsMap {
			if l.GroupID != nil && *l.GroupID == groupID {
				groupLessonsMap[lid] = l
			}
		}

		var statuses []student.StudentStatus
		if s.studentProvider != nil {
			statuses = s.studentProvider.ComputeStudentStatuses(st, stVisits, stPayments, lessonsMap, groupLessonsMap, today)
		}

		groupStudents = append(groupStudents, GroupStudentSummaryResponse{
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

func (s *Service) GetGroupLessons(ctx context.Context, groupID, ownerID uuid.UUID, from, to time.Time) ([]response.LessonResponse, error) {
	logger.InfoContext(ctx, "Getting lessons for group", "group_id", groupID.String(), "user_id", ownerID.String())
	if _, err := s.GetGroupByID(ctx, groupID, ownerID); err != nil {
		logger.WarnContext(ctx, "Group not found for getting lessons", "group_id", groupID.String(), "error", err, "user_id", ownerID.String())
		return nil, err
	}

	var lessons []response.LessonResponse
	if s.lessonProvider != nil {
		var err error
		lessons, err = s.lessonProvider.GetLessonsByGroupIDAndDateRange(ctx, groupID, ownerID, from, to)
		if err != nil {
			logger.ErrorContext(ctx, "Failed to fetch lessons for group", "group_id", groupID.String(), "error", err, "user_id", ownerID.String())
			return nil, err
		}
	}
	logger.DebugContext(ctx, "Retrieved group lessons", "group_id", groupID.String(), "count", len(lessons), "user_id", ownerID.String())
	return lessons, nil
}

func (s *Service) GetGroupReport(ctx context.Context, groupID, ownerID uuid.UUID, year, month int) (GroupReportResponse, error) {
	logger.InfoContext(ctx, "Getting group report", "group_id", groupID.String(), "year", year, "month", month, "user_id", ownerID.String())
	grp, err := s.GetGroupByID(ctx, groupID, ownerID)
	if err != nil {
		logger.WarnContext(ctx, "Group not found for report", "group_id", groupID.String(), "user_id", ownerID.String())
		return GroupReportResponse{}, err
	}

	firstDay := time.Date(year, time.Month(month), 1, 0, 0, 0, 0, time.UTC)
	lastDay := time.Date(year, time.Month(month)+1, 0, 23, 59, 59, 999999999, time.UTC)

	var (
		lessons      []response.LessonResponse
		studentLinks []db.GroupsModuleGroupStudent
	)

	g, gCtx := errgroup.WithContext(ctx)
	if s.lessonProvider != nil {
		g.Go(func() error {
			lList, err := s.lessonProvider.GetLessonsByGroupIDAndDateRange(gCtx, groupID, ownerID, firstDay, lastDay)
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
		return GroupReportResponse{}, err
	}

	lessonIDs := make([]uuid.UUID, 0, len(lessons))
	for _, lr := range lessons {
		lessonIDs = append(lessonIDs, lr.ID)
	}

	var lessonVisits []visit.VisitResponse
	if len(lessonIDs) > 0 && s.visitProvider != nil {
		lv, err := s.visitProvider.GetVisitsByLessonIDs(ctx, lessonIDs, ownerID)
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

	visitsByStudentID := make(map[uuid.UUID][]visit.VisitResponse, len(studentIDOrder))
	for _, sid := range studentIDOrder {
		visitsByStudentID[sid] = []visit.VisitResponse{}
	}
	for _, lv := range lessonVisits {
		visitsByStudentID[lv.StudentID] = append(visitsByStudentID[lv.StudentID], lv)
	}

	var (
		studentsList        []response.StudentResponse
		paymentsByStudentID map[uuid.UUID][]transaction.TransactionResponse
	)

	if len(studentIDOrder) > 0 {
		g2, g2Ctx := errgroup.WithContext(ctx)
		if s.studentProvider != nil {
			g2.Go(func() error {
				stRows, err := s.studentProvider.GetStudentsByIDs(g2Ctx, studentIDOrder, ownerID)
				if err != nil {
					return err
				}
				stMap := make(map[uuid.UUID]response.StudentResponse, len(stRows))
				for _, sr := range stRows {
					stMap[sr.ID] = sr
				}
				studentsList = make([]response.StudentResponse, 0, len(studentIDOrder))
				for _, sid := range studentIDOrder {
					if st, ok := stMap[sid]; ok {
						studentsList = append(studentsList, st)
					}
				}
				return nil
			})
		}
		if s.transactionProvider != nil {
			g2.Go(func() error {
				pm, err := s.transactionProvider.GetTransactionsByStudentIDs(g2Ctx, studentIDOrder, ownerID)
				if err != nil {
					return err
				}
				paymentsByStudentID = pm
				return nil
			})
		}
		if err := g2.Wait(); err != nil {
			logger.ErrorContext(ctx, "Failed to fetch students or payments for group report", "group_id", groupID.String(), "error", err, "user_id", ownerID.String())
			return GroupReportResponse{}, err
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

func (s *Service) GetGroupsByStudentIDs(ctx context.Context, studentIDs []uuid.UUID, ownerID uuid.UUID) (map[uuid.UUID][]response.GroupResponse, error) {
	if len(studentIDs) == 0 {
		logger.DebugContext(ctx, "No student IDs provided to get groups", "user_id", ownerID.String())
		return map[uuid.UUID][]response.GroupResponse{}, nil
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

	groupsMap := make(map[uuid.UUID]response.GroupResponse, len(allGroupIDs))
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

	groupsByStudent := make(map[uuid.UUID][]response.GroupResponse, len(studentIDs))
	for _, sid := range studentIDs {
		gIDs := studentGroupIDsMap[sid]
		stGroups := make([]response.GroupResponse, 0, len(gIDs))
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

func (s *Service) CreateGroup(ctx context.Context, req request.CreateGroupRequest, ownerID uuid.UUID) (response.GroupResponse, error) {
	logger.InfoContext(ctx, "Creating group", "name", req.Name, "user_id", ownerID.String())
	name, err := validator.ValidateRequiredName(req.Name, "name")
	if err != nil {
		logger.WarnContext(ctx, "Group name validation failed", "user_id", ownerID.String())
		return response.GroupResponse{}, err
	}

	if req.DefaultPrice != nil && *req.DefaultPrice <= 0 {
		logger.WarnContext(ctx, "Group default price must be greater than 0", "default_price", *req.DefaultPrice, "user_id", ownerID.String())
		return response.GroupResponse{}, pkgerrors.NewBadRequest("defaultPrice must be greater than 0")
	}

	taken, err := s.db.ExistsGroupByOwnerIDAndName(ctx, db.ExistsGroupByOwnerIDAndNameParams{
		OwnerID: ownerID,
		Name:    name,
	})
	if err != nil {
		logger.ErrorContext(ctx, "Failed to check group name uniqueness", "name", name, "error", err, "user_id", ownerID.String())
		return response.GroupResponse{}, err
	}
	if taken {
		logger.WarnContext(ctx, "Group with name already exists", "name", name, "user_id", ownerID.String())
		return response.GroupResponse{}, pkgerrors.NewConflict(
			ErrGroupNameNotUnique,
			fmt.Sprintf("A group named \"%s\" already exists", name),
		)
	}

	var uniqueStudentIDs []uuid.UUID
	if len(req.StudentIds) > 0 && s.studentProvider != nil {
		uniqueStudentIDs = utils.UniqueUUIDs(req.StudentIds)
		if err := validateStudentIDsExist(ctx, s.studentProvider, uniqueStudentIDs, ownerID, "group creation"); err != nil {
			return response.GroupResponse{}, err
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
		return response.GroupResponse{}, err
	}

	logger.InfoContext(ctx, "Group created successfully", "group_id", created.ID.String(), "name", created.Name, "students_count", len(uniqueStudentIDs), "user_id", ownerID.String())
	return toGroupResponse(created), nil
}

func (s *Service) UpdateGroup(ctx context.Context, groupID, ownerID uuid.UUID, updates map[string]any) (response.GroupResponse, error) {
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
			trimmed, err := validator.ValidateRequiredName(nameStr, "name")
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
					ErrGroupNameNotUnique,
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

		if rawSIDs, ok := updates["studentIds"]; ok && s.studentProvider != nil {
			requestedStudentIDs := types.ParseUUIDSlice(rawSIDs)
			if len(requestedStudentIDs) > 0 {
				if err := validateStudentIDsExist(ctx, s.studentProvider, requestedStudentIDs, ownerID, "group update"); err != nil {
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
		return response.GroupResponse{}, err
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
