package lesson

import (
	"context"
	"database/sql"
	"errors"
	"time"

	"github.com/google/uuid"
	"github.com/krivolapovdev/trenerio/internal/db"
	pkgerrors "github.com/krivolapovdev/trenerio/pkg/errors"
	"github.com/krivolapovdev/trenerio/pkg/logger"
	"github.com/krivolapovdev/trenerio/pkg/models"
	"github.com/krivolapovdev/trenerio/pkg/utils"
)

type FetchVisitsByLessonIDFunc func(ctx context.Context, lessonID, ownerID uuid.UUID) ([]models.VisitResponse, error)
type FetchStudentsByIDsFunc func(ctx context.Context, studentIDs []uuid.UUID, ownerID uuid.UUID) ([]models.StudentResponse, error)
type CreateVisitsFunc func(ctx context.Context, lessonID uuid.UUID, studentVisits []models.StudentVisit, ownerID uuid.UUID) error
type UpdateVisitsByLessonIDFunc func(ctx context.Context, lessonID uuid.UUID, requests []models.StudentVisit, ownerID uuid.UUID) error
type RemoveVisitsByLessonIDFunc func(ctx context.Context, lessonID, ownerID uuid.UUID) error

type Service interface {
	GetLessonByID(ctx context.Context, lessonID, ownerID uuid.UUID) (models.LessonResponse, error)
	GetLessonDetailsByID(ctx context.Context, lessonID, ownerID uuid.UUID) (models.LessonDetailsResponse, error)
	CreateLesson(ctx context.Context, req models.CreateLessonRequest, ownerID uuid.UUID) (models.LessonResponse, error)
	UpdateLesson(ctx context.Context, lessonID, ownerID uuid.UUID, req models.UpdateLessonRequest) (models.LessonResponse, error)
	DeleteLesson(ctx context.Context, lessonID, ownerID uuid.UUID) error
	GetLessonsByGroupIDAndDateRange(ctx context.Context, groupID, ownerID uuid.UUID, from, to time.Time) ([]models.LessonResponse, error)
	GetLessonsByIDs(ctx context.Context, lessonIDs []uuid.UUID, ownerID uuid.UUID) ([]models.LessonResponse, error)
}

type service struct {
	db                     *db.Queries
	sqlDB                  *sql.DB
	fetchVisitsByLessonID  FetchVisitsByLessonIDFunc
	fetchStudentsByIDs     FetchStudentsByIDsFunc
	createVisits           CreateVisitsFunc
	updateVisitsByLessonID UpdateVisitsByLessonIDFunc
	removeVisitsByLessonID RemoveVisitsByLessonIDFunc
}

func NewService(
	queries *db.Queries,
	sqlDB *sql.DB,
	fetchVisitsByLessonID FetchVisitsByLessonIDFunc,
	fetchStudentsByIDs FetchStudentsByIDsFunc,
	createVisits CreateVisitsFunc,
	updateVisitsByLessonID UpdateVisitsByLessonIDFunc,
	removeVisitsByLessonID RemoveVisitsByLessonIDFunc,
) Service {
	return &service{
		db:                     queries,
		sqlDB:                  sqlDB,
		fetchVisitsByLessonID:  fetchVisitsByLessonID,
		fetchStudentsByIDs:     fetchStudentsByIDs,
		createVisits:           createVisits,
		updateVisitsByLessonID: updateVisitsByLessonID,
		removeVisitsByLessonID: removeVisitsByLessonID,
	}
}

func (s *service) GetLessonByID(ctx context.Context, lessonID, ownerID uuid.UUID) (models.LessonResponse, error) {
	logger.InfoContext(ctx, "Getting lesson by id", "lesson_id", lessonID.String(), "user_id", ownerID.String())
	l, err := s.db.FindLessonByIDAndOwnerID(ctx, db.FindLessonByIDAndOwnerIDParams{
		ID:      lessonID,
		OwnerID: ownerID,
	})
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			logger.WarnContext(ctx, "Lesson not found", "lesson_id", lessonID.String(), "user_id", ownerID.String())
			return models.LessonResponse{}, pkgerrors.NewNotFound("Lesson", lessonID, ownerID)
		}
		logger.ErrorContext(ctx, "Failed to get lesson by id", "lesson_id", lessonID.String(), "error", err, "user_id", ownerID.String())
		return models.LessonResponse{}, err
	}
	logger.DebugContext(ctx, "Retrieved lesson by id", "lesson_id", lessonID.String(), "user_id", ownerID.String())
	return toLessonResponse(l), nil
}

func (s *service) GetLessonDetailsByID(ctx context.Context, lessonID, ownerID uuid.UUID) (models.LessonDetailsResponse, error) {
	logger.InfoContext(ctx, "Getting lesson details", "lesson_id", lessonID.String(), "user_id", ownerID.String())
	lessonResp, err := s.GetLessonByID(ctx, lessonID, ownerID)
	if err != nil {
		logger.WarnContext(ctx, "Failed to get lesson for details", "lesson_id", lessonID.String(), "error", err, "user_id", ownerID.String())
		return models.LessonDetailsResponse{}, err
	}

	visitResponses, err := s.fetchVisitsByLessonID(ctx, lessonID, ownerID)
	if err != nil {
		logger.ErrorContext(ctx, "Failed to fetch visits for lesson details", "lesson_id", lessonID.String(), "error", err, "user_id", ownerID.String())
		return models.LessonDetailsResponse{}, err
	}

	studentIDs := make([]uuid.UUID, 0, len(visitResponses))
	for _, vr := range visitResponses {
		studentIDs = append(studentIDs, vr.StudentID)
	}
	studentIDs = utils.UniqueUUIDs(studentIDs)

	students := make([]models.StudentResponse, 0, len(studentIDs))
	if len(studentIDs) > 0 && s.fetchStudentsByIDs != nil {
		stRows, err := s.fetchStudentsByIDs(ctx, studentIDs, ownerID)
		if err != nil {
			logger.ErrorContext(ctx, "Failed to fetch students for lesson details", "lesson_id", lessonID.String(), "error", err, "user_id", ownerID.String())
			return models.LessonDetailsResponse{}, err
		}
		stMap := make(map[uuid.UUID]models.StudentResponse, len(stRows))
		for _, sr := range stRows {
			stMap[sr.ID] = sr
		}
		for _, sid := range studentIDs {
			if st, ok := stMap[sid]; ok {
				students = append(students, st)
			}
		}
	}

	logger.InfoContext(ctx, "Lesson details retrieved", "lesson_id", lessonID.String(), "visits_count", len(visitResponses), "students_count", len(students), "user_id", ownerID.String())
	return models.LessonDetailsResponse{
		ID:            lessonResp.ID,
		Date:          lessonResp.Date,
		CreatedAt:     lessonResp.CreatedAt,
		GroupID:       lessonResp.GroupID,
		StudentVisits: visitResponses,
		Students:      students,
	}, nil
}

func (s *service) CreateLesson(ctx context.Context, req models.CreateLessonRequest, ownerID uuid.UUID) (models.LessonResponse, error) {
	logger.InfoContext(ctx, "Creating lesson", "date", req.Date.Format(time.RFC3339), "user_id", ownerID.String())
	var groupID uuid.NullUUID
	if req.GroupID != nil {
		groupID = uuid.NullUUID{UUID: *req.GroupID, Valid: true}
	}

	createdLesson, err := s.db.CreateLesson(ctx, db.CreateLessonParams{
		OwnerID: ownerID,
		GroupID: groupID,
		Date:    req.Date,
	})
	if err != nil {
		logger.ErrorContext(ctx, "Failed to create lesson record", "error", err, "user_id", ownerID.String())
		return models.LessonResponse{}, err
	}

	if len(req.Students) > 0 && s.createVisits != nil {
		studentVisitMap := make(map[uuid.UUID]models.StudentVisit, len(req.Students))
		for _, sv := range req.Students {
			studentVisitMap[sv.StudentID] = sv
		}
		uniqueVisits := make([]models.StudentVisit, 0, len(studentVisitMap))
		for _, sv := range studentVisitMap {
			uniqueVisits = append(uniqueVisits, sv)
		}

		if err := s.createVisits(ctx, createdLesson.ID, uniqueVisits, ownerID); err != nil {
			logger.ErrorContext(ctx, "Failed to create visits for lesson, rolling back lesson creation", "lesson_id", createdLesson.ID.String(), "error", err, "user_id", ownerID.String())
			_ = s.db.DeleteLessonByIDAndOwnerID(ctx, db.DeleteLessonByIDAndOwnerIDParams{
				ID:      createdLesson.ID,
				OwnerID: ownerID,
			})
			return models.LessonResponse{}, err
		}
	}

	logger.InfoContext(ctx, "Lesson created successfully", "lesson_id", createdLesson.ID.String(), "visits_count", len(req.Students), "user_id", ownerID.String())
	return toLessonResponse(createdLesson), nil
}

func (s *service) UpdateLesson(ctx context.Context, lessonID, ownerID uuid.UUID, req models.UpdateLessonRequest) (models.LessonResponse, error) {
	logger.InfoContext(ctx, "Updating lesson", "lesson_id", lessonID.String(), "user_id", ownerID.String())
	existingLesson, err := s.db.FindLessonByIDAndOwnerID(ctx, db.FindLessonByIDAndOwnerIDParams{
		ID:      lessonID,
		OwnerID: ownerID,
	})
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			logger.WarnContext(ctx, "Lesson to update not found", "lesson_id", lessonID.String(), "user_id", ownerID.String())
			return models.LessonResponse{}, pkgerrors.NewNotFound("Lesson", lessonID, ownerID)
		}
		logger.ErrorContext(ctx, "Failed to find lesson for update", "lesson_id", lessonID.String(), "error", err, "user_id", ownerID.String())
		return models.LessonResponse{}, err
	}

	newDate := existingLesson.Date
	if req.Date != nil {
		newDate = *req.Date
	}

	updatedLesson, err := s.db.UpdateLesson(ctx, db.UpdateLessonParams{
		ID:      lessonID,
		OwnerID: ownerID,
		Date:    newDate,
	})
	if err != nil {
		logger.ErrorContext(ctx, "Failed to update lesson record", "lesson_id", lessonID.String(), "error", err, "user_id", ownerID.String())
		return models.LessonResponse{}, err
	}

	if req.Students != nil && s.updateVisitsByLessonID != nil {
		if err := s.updateVisitsByLessonID(ctx, lessonID, req.Students, ownerID); err != nil {
			logger.ErrorContext(ctx, "Failed to update visits for lesson", "lesson_id", lessonID.String(), "error", err, "user_id", ownerID.String())
			return models.LessonResponse{}, err
		}
	}

	logger.InfoContext(ctx, "Lesson updated successfully", "lesson_id", lessonID.String(), "user_id", ownerID.String())
	return toLessonResponse(updatedLesson), nil
}

func (s *service) DeleteLesson(ctx context.Context, lessonID, ownerID uuid.UUID) error {
	logger.InfoContext(ctx, "Deleting lesson", "lesson_id", lessonID.String(), "user_id", ownerID.String())
	_, err := s.db.FindLessonByIDAndOwnerID(ctx, db.FindLessonByIDAndOwnerIDParams{
		ID:      lessonID,
		OwnerID: ownerID,
	})
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			logger.WarnContext(ctx, "Lesson to delete not found", "lesson_id", lessonID.String(), "user_id", ownerID.String())
			return pkgerrors.NewNotFound("Lesson", lessonID, ownerID)
		}
		logger.ErrorContext(ctx, "Failed to find lesson for deletion", "lesson_id", lessonID.String(), "error", err, "user_id", ownerID.String())
		return err
	}

	if s.removeVisitsByLessonID != nil {
		if err := s.removeVisitsByLessonID(ctx, lessonID, ownerID); err != nil {
			logger.ErrorContext(ctx, "Failed to remove visits for lesson deletion", "lesson_id", lessonID.String(), "error", err, "user_id", ownerID.String())
			return err
		}
	}

	if err := s.db.DeleteLessonByIDAndOwnerID(ctx, db.DeleteLessonByIDAndOwnerIDParams{
		ID:      lessonID,
		OwnerID: ownerID,
	}); err != nil {
		logger.ErrorContext(ctx, "Failed to delete lesson record", "lesson_id", lessonID.String(), "error", err, "user_id", ownerID.String())
		return err
	}

	logger.InfoContext(ctx, "Lesson deleted successfully", "lesson_id", lessonID.String(), "user_id", ownerID.String())
	return nil
}

func (s *service) GetLessonsByGroupIDAndDateRange(ctx context.Context, groupID, ownerID uuid.UUID, from, to time.Time) ([]models.LessonResponse, error) {
	logger.InfoContext(ctx, "Getting lessons by group id and date range", "group_id", groupID.String(), "user_id", ownerID.String())
	rows, err := s.db.FindLessonsByGroupIDAndDateBetween(ctx, db.FindLessonsByGroupIDAndDateBetweenParams{
		GroupID: uuid.NullUUID{UUID: groupID, Valid: true},
		OwnerID: ownerID,
		Date:    from,
		Date_2:  to,
	})
	if err != nil {
		logger.ErrorContext(ctx, "Failed to get lessons by group id and date range", "group_id", groupID.String(), "error", err, "user_id", ownerID.String())
		return nil, err
	}
	lessons := make([]models.LessonResponse, 0, len(rows))
	for _, r := range rows {
		lessons = append(lessons, toLessonResponse(r))
	}
	logger.DebugContext(ctx, "Retrieved lessons by group id and date range", "group_id", groupID.String(), "count", len(lessons), "user_id", ownerID.String())
	return lessons, nil
}

func (s *service) GetLessonsByIDs(ctx context.Context, lessonIDs []uuid.UUID, ownerID uuid.UUID) ([]models.LessonResponse, error) {
	if len(lessonIDs) == 0 {
		logger.DebugContext(ctx, "No lesson IDs provided to get lessons", "user_id", ownerID.String())
		return []models.LessonResponse{}, nil
	}
	rows, err := s.db.FindLessonsByIDsAndOwnerID(ctx, db.FindLessonsByIDsAndOwnerIDParams{
		OwnerID: ownerID,
		Column2: lessonIDs,
	})
	if err != nil {
		logger.ErrorContext(ctx, "Failed to get lessons by IDs", "count", len(lessonIDs), "error", err, "user_id", ownerID.String())
		return nil, err
	}
	lessons := make([]models.LessonResponse, 0, len(rows))
	for _, r := range rows {
		lessons = append(lessons, toLessonResponse(r))
	}
	logger.DebugContext(ctx, "Retrieved lessons by IDs", "count", len(lessons), "user_id", ownerID.String())
	return lessons, nil
}

func toLessonResponse(l db.LessonsModuleLesson) models.LessonResponse {
	var groupID *uuid.UUID
	if l.GroupID.Valid {
		groupID = &l.GroupID.UUID
	}
	return models.LessonResponse{
		ID:        l.ID,
		Date:      l.Date,
		CreatedAt: l.CreatedAt,
		GroupID:   groupID,
	}
}
