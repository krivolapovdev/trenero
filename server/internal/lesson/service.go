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
)

type FetchVisitsByLessonIDFunc func(ctx context.Context, lessonID, ownerID uuid.UUID) ([]models.VisitResponse, error)
type FetchStudentsByIDsFunc func(ctx context.Context, studentIDs []uuid.UUID, ownerID uuid.UUID) ([]models.StudentResponse, error)
type CreateVisitsFunc func(ctx context.Context, lessonID uuid.UUID, studentVisits []models.StudentVisit, ownerID uuid.UUID) error
type UpdateVisitsByLessonIDFunc func(ctx context.Context, lessonID uuid.UUID, requests []models.StudentVisit, ownerID uuid.UUID) error
type RemoveVisitsByLessonIDFunc func(ctx context.Context, lessonID, ownerID uuid.UUID) error

type Service struct {
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
) *Service {
	return &Service{
		db:                     queries,
		sqlDB:                  sqlDB,
		fetchVisitsByLessonID:  fetchVisitsByLessonID,
		fetchStudentsByIDs:     fetchStudentsByIDs,
		createVisits:           createVisits,
		updateVisitsByLessonID: updateVisitsByLessonID,
		removeVisitsByLessonID: removeVisitsByLessonID,
	}
}

func (s *Service) GetLessonByID(ctx context.Context, lessonID, ownerID uuid.UUID) (models.LessonResponse, error) {
	logger.InfoContext(ctx, "Getting lesson by id", "lesson_id", lessonID.String(), "user_id", ownerID.String())
	l, err := s.db.FindLessonByIDAndOwnerID(ctx, db.FindLessonByIDAndOwnerIDParams{
		ID:      lessonID,
		OwnerID: ownerID,
	})
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return models.LessonResponse{}, &pkgerrors.NotFoundError{
				Entity:  "Lesson",
				ID:      lessonID,
				OwnerID: ownerID,
			}
		}
		return models.LessonResponse{}, err
	}
	return toLessonResponse(l), nil
}

func (s *Service) GetLessonDetailsByID(ctx context.Context, lessonID, ownerID uuid.UUID) (models.LessonDetailsResponse, error) {
	logger.InfoContext(ctx, "Getting lesson details", "lesson_id", lessonID.String(), "user_id", ownerID.String())
	lessonResp, err := s.GetLessonByID(ctx, lessonID, ownerID)
	if err != nil {
		return models.LessonDetailsResponse{}, err
	}

	visitResponses, err := s.fetchVisitsByLessonID(ctx, lessonID, ownerID)
	if err != nil {
		return models.LessonDetailsResponse{}, err
	}

	studentIDs := make([]uuid.UUID, 0, len(visitResponses))
	seenStudentIDs := make(map[uuid.UUID]bool)
	for _, vr := range visitResponses {
		if !seenStudentIDs[vr.StudentID] {
			seenStudentIDs[vr.StudentID] = true
			studentIDs = append(studentIDs, vr.StudentID)
		}
	}

	students := make([]models.StudentResponse, 0, len(studentIDs))
	if len(studentIDs) > 0 {
		stRows, err := s.fetchStudentsByIDs(ctx, studentIDs, ownerID)
		if err != nil {
			return models.LessonDetailsResponse{}, err
		}
		stMap := make(map[uuid.UUID]models.StudentResponse)
		for _, sr := range stRows {
			stMap[sr.ID] = sr
		}
		for _, sid := range studentIDs {
			if st, ok := stMap[sid]; ok {
				students = append(students, st)
			}
		}
	}

	return models.LessonDetailsResponse{
		ID:            lessonResp.ID,
		Date:          lessonResp.Date,
		CreatedAt:     lessonResp.CreatedAt,
		GroupID:       lessonResp.GroupID,
		StudentVisits: visitResponses,
		Students:      students,
	}, nil
}

func (s *Service) CreateLesson(ctx context.Context, req models.CreateLessonRequest, ownerID uuid.UUID) (models.LessonResponse, error) {
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
		return models.LessonResponse{}, err
	}

	if len(req.Students) > 0 {
		studentVisitMap := make(map[uuid.UUID]models.StudentVisit)
		for _, sv := range req.Students {
			studentVisitMap[sv.StudentID] = sv
		}
		uniqueVisits := make([]models.StudentVisit, 0, len(studentVisitMap))
		for _, sv := range studentVisitMap {
			uniqueVisits = append(uniqueVisits, sv)
		}

		if err := s.createVisits(ctx, createdLesson.ID, uniqueVisits, ownerID); err != nil {
			_ = s.db.DeleteLessonByIDAndOwnerID(ctx, db.DeleteLessonByIDAndOwnerIDParams{
				ID:      createdLesson.ID,
				OwnerID: ownerID,
			})
			return models.LessonResponse{}, err
		}
	}

	return toLessonResponse(createdLesson), nil
}

func (s *Service) UpdateLesson(ctx context.Context, lessonID, ownerID uuid.UUID, req models.UpdateLessonRequest) (models.LessonResponse, error) {
	logger.InfoContext(ctx, "Updating lesson", "lesson_id", lessonID.String(), "user_id", ownerID.String())
	existingLesson, err := s.db.FindLessonByIDAndOwnerID(ctx, db.FindLessonByIDAndOwnerIDParams{
		ID:      lessonID,
		OwnerID: ownerID,
	})
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return models.LessonResponse{}, &pkgerrors.NotFoundError{
				Entity:  "Lesson",
				ID:      lessonID,
				OwnerID: ownerID,
			}
		}
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
		return models.LessonResponse{}, err
	}

	if req.Students != nil {
		if err := s.updateVisitsByLessonID(ctx, lessonID, req.Students, ownerID); err != nil {
			return models.LessonResponse{}, err
		}
	}

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
			return &pkgerrors.NotFoundError{
				Entity:  "Lesson",
				ID:      lessonID,
				OwnerID: ownerID,
			}
		}
		return err
	}

	if err := s.removeVisitsByLessonID(ctx, lessonID, ownerID); err != nil {
		return err
	}

	return s.db.DeleteLessonByIDAndOwnerID(ctx, db.DeleteLessonByIDAndOwnerIDParams{
		ID:      lessonID,
		OwnerID: ownerID,
	})
}

func (s *Service) GetLessonsByGroupIDAndDateRange(ctx context.Context, groupID, ownerID uuid.UUID, from, to time.Time) ([]models.LessonResponse, error) {
	logger.InfoContext(ctx, "Getting lessons by group id and date range", "group_id", groupID.String(), "user_id", ownerID.String())
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
		res = append(res, toLessonResponse(r))
	}
	return res, nil
}

func (s *Service) GetLessonsByIDs(ctx context.Context, lessonIDs []uuid.UUID, ownerID uuid.UUID) ([]models.LessonResponse, error) {
	if len(lessonIDs) == 0 {
		return []models.LessonResponse{}, nil
	}
	rows, err := s.db.FindLessonsByIDsAndOwnerID(ctx, db.FindLessonsByIDsAndOwnerIDParams{
		OwnerID: ownerID,
		Column2: lessonIDs,
	})
	if err != nil {
		return nil, err
	}
	res := make([]models.LessonResponse, 0, len(rows))
	for _, r := range rows {
		res = append(res, toLessonResponse(r))
	}
	return res, nil
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
