package lesson

import (
	"context"
	"database/sql"
	"errors"
	"time"

	"github.com/google/uuid"
	"github.com/krivolapovdev/trenerio/internal/db"
	pkgerrors "github.com/krivolapovdev/trenerio/internal/shared/errors"
	"github.com/krivolapovdev/trenerio/internal/shared/logger"
	"github.com/krivolapovdev/trenerio/internal/shared/request"
	"github.com/krivolapovdev/trenerio/internal/shared/response"
	"github.com/krivolapovdev/trenerio/internal/shared/utils"
	"github.com/krivolapovdev/trenerio/internal/shared/validator"
)

type VisitProvider interface {
	GetVisitsByLessonID(ctx context.Context, lessonID, ownerID uuid.UUID) ([]response.VisitResponse, error)
	CreateVisits(ctx context.Context, lessonID uuid.UUID, studentVisits []request.StudentVisit, ownerID uuid.UUID) error
	UpdateVisitsByLessonID(ctx context.Context, lessonID uuid.UUID, requests []request.StudentVisit, ownerID uuid.UUID) error
	RemoveVisitsByLessonID(ctx context.Context, lessonID, ownerID uuid.UUID) error
}

type StudentProvider interface {
	GetStudentsByIDs(ctx context.Context, studentIDs []uuid.UUID, ownerID uuid.UUID) ([]response.StudentResponse, error)
}

type Service struct {
	db              *db.Queries
	sqlDB           *sql.DB
	visitProvider   VisitProvider
	studentProvider StudentProvider
}

func NewService(
	queries *db.Queries,
	sqlDB *sql.DB,
	visitProvider VisitProvider,
	studentProvider StudentProvider,
) *Service {
	return &Service{
		db:              queries,
		sqlDB:           sqlDB,
		visitProvider:   visitProvider,
		studentProvider: studentProvider,
	}
}

func (s *Service) withTx(ctx context.Context, fn func(qtx *db.Queries) error) error {
	if s.sqlDB == nil {
		return fn(s.db)
	}
	return db.WithTx(ctx, s.sqlDB, s.db, fn)
}

func (s *Service) GetLessonByID(ctx context.Context, lessonID, ownerID uuid.UUID) (response.LessonResponse, error) {
	logger.InfoContext(ctx, "Getting lesson by id", "lesson_id", lessonID.String(), "user_id", ownerID.String())

	l, err := s.db.FindLessonByIDAndOwnerID(ctx, db.FindLessonByIDAndOwnerIDParams{
		ID:      lessonID,
		OwnerID: ownerID,
	})

	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			logger.WarnContext(ctx, "Lesson not found", "lesson_id", lessonID.String(), "user_id", ownerID.String())
			return response.LessonResponse{}, pkgerrors.NewNotFound("Lesson", lessonID, ownerID)
		}

		logger.ErrorContext(ctx, "Failed to get lesson by id", "lesson_id", lessonID.String(), "error", err, "user_id", ownerID.String())
		return response.LessonResponse{}, err
	}

	logger.DebugContext(ctx, "Retrieved lesson by id", "lesson_id", lessonID.String(), "user_id", ownerID.String())

	return toLessonResponse(l), nil
}

func (s *Service) GetLessonDetailsByID(ctx context.Context, lessonID, ownerID uuid.UUID) (response.LessonDetailsResponse, error) {
	logger.InfoContext(ctx, "Getting lesson details", "lesson_id", lessonID.String(), "user_id", ownerID.String())
	lessonResp, err := s.GetLessonByID(ctx, lessonID, ownerID)
	if err != nil {
		logger.WarnContext(ctx, "Failed to get lesson for details", "lesson_id", lessonID.String(), "error", err, "user_id", ownerID.String())
		return response.LessonDetailsResponse{}, err
	}

	var visitResponses []response.VisitResponse
	if s.visitProvider != nil {
		var err error
		visitResponses, err = s.visitProvider.GetVisitsByLessonID(ctx, lessonID, ownerID)
		if err != nil {
			logger.ErrorContext(ctx, "Failed to fetch visits for lesson details", "lesson_id", lessonID.String(), "error", err, "user_id", ownerID.String())
			return response.LessonDetailsResponse{}, err
		}
	}

	studentIDs := make([]uuid.UUID, 0, len(visitResponses))
	for _, vr := range visitResponses {
		studentIDs = append(studentIDs, vr.StudentID)
	}
	studentIDs = utils.UniqueUUIDs(studentIDs)

	students := make([]response.StudentResponse, 0, len(studentIDs))
	if len(studentIDs) > 0 && s.studentProvider != nil {
		stRows, err := s.studentProvider.GetStudentsByIDs(ctx, studentIDs, ownerID)
		if err != nil {
			logger.ErrorContext(ctx, "Failed to fetch students for lesson details", "lesson_id", lessonID.String(), "error", err, "user_id", ownerID.String())
			return response.LessonDetailsResponse{}, err
		}
		stMap := make(map[uuid.UUID]response.StudentResponse, len(stRows))
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
	return response.LessonDetailsResponse{
		ID:            lessonResp.ID,
		Date:          lessonResp.Date,
		CreatedAt:     lessonResp.CreatedAt,
		GroupID:       lessonResp.GroupID,
		StudentVisits: visitResponses,
		Students:      students,
	}, nil
}

func (s *Service) CreateLesson(ctx context.Context, req request.CreateLessonRequest, ownerID uuid.UUID) (response.LessonResponse, error) {
	logger.InfoContext(ctx, "Creating lesson", "date", req.Date.Format(time.RFC3339), "user_id", ownerID.String())
	if err := validator.ValidateDateNotFuture(req.Date, "date"); err != nil {
		logger.WarnContext(ctx, "Lesson date cannot be in the future", "date", req.Date.Format(time.RFC3339), "user_id", ownerID.String())
		return response.LessonResponse{}, err
	}

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
		return response.LessonResponse{}, err
	}

	if len(req.Students) > 0 && s.visitProvider != nil {
		studentVisitMap := make(map[uuid.UUID]request.StudentVisit, len(req.Students))
		for _, sv := range req.Students {
			studentVisitMap[sv.StudentID] = sv
		}
		uniqueVisits := make([]request.StudentVisit, 0, len(studentVisitMap))
		for _, sv := range studentVisitMap {
			uniqueVisits = append(uniqueVisits, sv)
		}

		if err := s.visitProvider.CreateVisits(ctx, createdLesson.ID, uniqueVisits, ownerID); err != nil {
			logger.ErrorContext(ctx, "Failed to create visits for lesson, rolling back lesson creation", "lesson_id", createdLesson.ID.String(), "error", err, "user_id", ownerID.String())
			_ = s.db.DeleteLessonByIDAndOwnerID(ctx, db.DeleteLessonByIDAndOwnerIDParams{
				ID:      createdLesson.ID,
				OwnerID: ownerID,
			})
			return response.LessonResponse{}, err
		}
	}

	logger.InfoContext(ctx, "Lesson created successfully", "lesson_id", createdLesson.ID.String(), "visits_count", len(req.Students), "user_id", ownerID.String())
	return toLessonResponse(createdLesson), nil
}

func (s *Service) UpdateLesson(ctx context.Context, lessonID, ownerID uuid.UUID, req request.UpdateLessonRequest) (response.LessonResponse, error) {
	logger.InfoContext(ctx, "Updating lesson", "lesson_id", lessonID.String(), "user_id", ownerID.String())
	if req.Date != nil {
		if err := validator.ValidateDateNotFuture(*req.Date, "date"); err != nil {
			logger.WarnContext(ctx, "Updated lesson date cannot be in the future", "date", req.Date.Format(time.RFC3339), "user_id", ownerID.String())
			return response.LessonResponse{}, err
		}
	}

	existingLesson, err := s.db.FindLessonByIDAndOwnerID(ctx, db.FindLessonByIDAndOwnerIDParams{
		ID:      lessonID,
		OwnerID: ownerID,
	})
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			logger.WarnContext(ctx, "Lesson to update not found", "lesson_id", lessonID.String(), "user_id", ownerID.String())
			return response.LessonResponse{}, pkgerrors.NewNotFound("Lesson", lessonID, ownerID)
		}
		logger.ErrorContext(ctx, "Failed to find lesson for update", "lesson_id", lessonID.String(), "error", err, "user_id", ownerID.String())
		return response.LessonResponse{}, err
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
		return response.LessonResponse{}, err
	}

	if req.Students != nil && s.visitProvider != nil {
		if err := s.visitProvider.UpdateVisitsByLessonID(ctx, lessonID, req.Students, ownerID); err != nil {
			logger.ErrorContext(ctx, "Failed to update visits for lesson", "lesson_id", lessonID.String(), "error", err, "user_id", ownerID.String())
			return response.LessonResponse{}, err
		}
	}

	logger.InfoContext(ctx, "Lesson updated successfully", "lesson_id", lessonID.String(), "user_id", ownerID.String())
	return toLessonResponse(updatedLesson), nil
}

func (s *Service) DeleteLesson(ctx context.Context, lessonID, ownerID uuid.UUID) error {
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

	err = s.withTx(ctx, func(qtx *db.Queries) error {
		if err := qtx.DeleteVisitsByLessonIDAndOwnerID(ctx, db.DeleteVisitsByLessonIDAndOwnerIDParams{
			LessonID: lessonID,
			OwnerID:  ownerID,
		}); err != nil {
			logger.ErrorContext(ctx, "Failed to remove visits for lesson deletion", "lesson_id", lessonID.String(), "error", err, "user_id", ownerID.String())
			return err
		}

		if err := qtx.DeleteLessonByIDAndOwnerID(ctx, db.DeleteLessonByIDAndOwnerIDParams{
			ID:      lessonID,
			OwnerID: ownerID,
		}); err != nil {
			logger.ErrorContext(ctx, "Failed to delete lesson record", "lesson_id", lessonID.String(), "error", err, "user_id", ownerID.String())
			return err
		}

		return nil
	})
	if err != nil {
		return err
	}

	logger.InfoContext(ctx, "Lesson deleted successfully", "lesson_id", lessonID.String(), "user_id", ownerID.String())
	return nil
}

func (s *Service) DeleteLessonsByGroupID(ctx context.Context, groupID, ownerID uuid.UUID) error {
	logger.InfoContext(ctx, "Deleting lessons by group id", "group_id", groupID.String(), "user_id", ownerID.String())
	return s.withTx(ctx, func(qtx *db.Queries) error {
		lessons, err := qtx.FindAllLessonsByGroupIDAndOwnerID(ctx, db.FindAllLessonsByGroupIDAndOwnerIDParams{
			GroupID: uuid.NullUUID{UUID: groupID, Valid: true},
			OwnerID: ownerID,
		})
		if err != nil {
			logger.ErrorContext(ctx, "Failed to find lessons for group deletion", "group_id", groupID.String(), "error", err, "user_id", ownerID.String())
			return err
		}
		for _, l := range lessons {
			if err := qtx.DeleteVisitsByLessonIDAndOwnerID(ctx, db.DeleteVisitsByLessonIDAndOwnerIDParams{
				LessonID: l.ID,
				OwnerID:  ownerID,
			}); err != nil {
				logger.ErrorContext(ctx, "Failed to remove visits for lesson deletion", "lesson_id", l.ID.String(), "error", err, "user_id", ownerID.String())
				return err
			}
		}
		return qtx.DeleteLessonsByGroupIDAndOwnerID(ctx, db.DeleteLessonsByGroupIDAndOwnerIDParams{
			GroupID: uuid.NullUUID{UUID: groupID, Valid: true},
			OwnerID: ownerID,
		})
	})
}

func (s *Service) GetLessonsByGroupIDAndDateRange(ctx context.Context, groupID, ownerID uuid.UUID, from, to time.Time) ([]response.LessonResponse, error) {
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
	lessons := make([]response.LessonResponse, 0, len(rows))
	for _, r := range rows {
		lessons = append(lessons, toLessonResponse(r))
	}
	logger.DebugContext(ctx, "Retrieved lessons by group id and date range", "group_id", groupID.String(), "count", len(lessons), "user_id", ownerID.String())
	return lessons, nil
}

func (s *Service) GetLessonsByIDs(ctx context.Context, lessonIDs []uuid.UUID, ownerID uuid.UUID) ([]response.LessonResponse, error) {
	if len(lessonIDs) == 0 {
		logger.DebugContext(ctx, "No lesson IDs provided to get lessons", "user_id", ownerID.String())
		return []response.LessonResponse{}, nil
	}
	rows, err := s.db.FindLessonsByIDsAndOwnerID(ctx, db.FindLessonsByIDsAndOwnerIDParams{
		OwnerID: ownerID,
		Column2: lessonIDs,
	})
	if err != nil {
		logger.ErrorContext(ctx, "Failed to get lessons by IDs", "count", len(lessonIDs), "error", err, "user_id", ownerID.String())
		return nil, err
	}
	lessons := make([]response.LessonResponse, 0, len(rows))
	for _, r := range rows {
		lessons = append(lessons, toLessonResponse(r))
	}
	logger.DebugContext(ctx, "Retrieved lessons by IDs", "count", len(lessons), "user_id", ownerID.String())
	return lessons, nil
}

func toLessonResponse(l db.LessonsModuleLesson) response.LessonResponse {
	var groupID *uuid.UUID
	if l.GroupID.Valid {
		groupID = &l.GroupID.UUID
	}
	return response.LessonResponse{
		ID:        l.ID,
		Date:      l.Date,
		CreatedAt: l.CreatedAt,
		GroupID:   groupID,
	}
}
