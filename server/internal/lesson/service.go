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

	visitsRows, err := s.db.FindVisitsByLessonIDAndOwnerID(ctx, db.FindVisitsByLessonIDAndOwnerIDParams{
		LessonID: lessonID,
		OwnerID:  ownerID,
	})
	if err != nil {
		return models.LessonDetailsResponse{}, err
	}

	visitResponses := make([]models.VisitResponse, 0, len(visitsRows))
	studentIDs := make([]uuid.UUID, 0, len(visitsRows))
	seenStudentIDs := make(map[uuid.UUID]bool)

	for _, vr := range visitsRows {
		visitResponses = append(visitResponses, models.VisitResponse{
			ID:        vr.ID,
			Status:    types.VisitStatus(vr.Status),
			Type:      types.VisitType(vr.Type),
			LessonID:  vr.LessonID,
			StudentID: vr.StudentID,
			CreatedAt: vr.CreatedAt,
		})
		if !seenStudentIDs[vr.StudentID] {
			seenStudentIDs[vr.StudentID] = true
			studentIDs = append(studentIDs, vr.StudentID)
		}
	}

	students := make([]models.StudentResponse, 0, len(studentIDs))
	if len(studentIDs) > 0 {
		stRows, err := s.db.FindStudentsByIDsAndOwnerID(ctx, db.FindStudentsByIDsAndOwnerIDParams{
			OwnerID: ownerID,
			Column2: studentIDs,
		})
		if err != nil {
			return models.LessonDetailsResponse{}, err
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
	var createdLesson db.LessonsModuleLesson

	err := s.withTx(ctx, func(qtx *db.Queries) error {
		var groupID uuid.NullUUID
		if req.GroupID != nil {
			groupID = uuid.NullUUID{UUID: *req.GroupID, Valid: true}
		}

		var err error
		createdLesson, err = qtx.CreateLesson(ctx, db.CreateLessonParams{
			OwnerID: ownerID,
			GroupID: groupID,
			Date:    req.Date,
		})
		if err != nil {
			return err
		}

		studentVisitMap := make(map[uuid.UUID]models.StudentVisit)
		for _, sv := range req.Students {
			studentVisitMap[sv.StudentID] = sv
		}

		for _, sv := range studentVisitMap {
			_, err := qtx.CreateVisit(ctx, db.CreateVisitParams{
				OwnerID:   ownerID,
				LessonID:  createdLesson.ID,
				StudentID: sv.StudentID,
				Status:    db.VisitsModuleVisitStatus(sv.Status),
				Type:      db.VisitsModuleVisitType(sv.Type),
			})
			if err != nil {
				return err
			}
		}

		return nil
	})
	if err != nil {
		return models.LessonResponse{}, err
	}

	return toLessonResponse(createdLesson), nil
}

func (s *Service) UpdateLesson(ctx context.Context, lessonID, ownerID uuid.UUID, req models.UpdateLessonRequest) (models.LessonResponse, error) {
	logger.InfoContext(ctx, "Updating lesson", "lesson_id", lessonID.String(), "user_id", ownerID.String())
	var updatedLesson db.LessonsModuleLesson

	err := s.withTx(ctx, func(qtx *db.Queries) error {
		existingLesson, err := qtx.FindLessonByIDAndOwnerID(ctx, db.FindLessonByIDAndOwnerIDParams{
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

		newDate := existingLesson.Date
		if req.Date != nil {
			newDate = *req.Date
		}

		updatedLesson, err = qtx.UpdateLesson(ctx, db.UpdateLessonParams{
			ID:      lessonID,
			OwnerID: ownerID,
			Date:    newDate,
		})
		if err != nil {
			return err
		}

		if req.Students != nil {
			existingVisits, err := qtx.FindVisitsByLessonIDAndOwnerID(ctx, db.FindVisitsByLessonIDAndOwnerIDParams{
				LessonID: lessonID,
				OwnerID:  ownerID,
			})
			if err != nil {
				return err
			}

			existingMap := make(map[uuid.UUID]db.VisitsModuleVisit)
			for _, ev := range existingVisits {
				existingMap[ev.StudentID] = ev
			}

			reqMap := make(map[uuid.UUID]models.StudentVisit)
			for _, r := range req.Students {
				reqMap[r.StudentID] = r
			}

			for sid, ev := range existingMap {
				if _, ok := reqMap[sid]; !ok {
					if err := qtx.DeleteVisitByIDAndOwnerID(ctx, db.DeleteVisitByIDAndOwnerIDParams{
						ID:      ev.ID,
						OwnerID: ownerID,
					}); err != nil {
						return err
					}
				}
			}

			for sid, r := range reqMap {
				if ev, ok := existingMap[sid]; ok {
					_, err := qtx.UpdateVisit(ctx, db.UpdateVisitParams{
						ID:      ev.ID,
						OwnerID: ownerID,
						Status:  db.VisitsModuleVisitStatus(r.Status),
						Type:    db.VisitsModuleVisitType(r.Type),
					})
					if err != nil {
						return err
					}
				} else {
					_, err := qtx.CreateVisit(ctx, db.CreateVisitParams{
						OwnerID:   ownerID,
						LessonID:  lessonID,
						StudentID: r.StudentID,
						Status:    db.VisitsModuleVisitStatus(r.Status),
						Type:      db.VisitsModuleVisitType(r.Type),
					})
					if err != nil {
						return err
					}
				}
			}
		}

		return nil
	})
	if err != nil {
		return models.LessonResponse{}, err
	}

	return toLessonResponse(updatedLesson), nil
}

func (s *Service) DeleteLesson(ctx context.Context, lessonID, ownerID uuid.UUID) error {
	logger.InfoContext(ctx, "Deleting lesson", "lesson_id", lessonID.String(), "user_id", ownerID.String())
	return s.withTx(ctx, func(qtx *db.Queries) error {
		_, err := qtx.FindLessonByIDAndOwnerID(ctx, db.FindLessonByIDAndOwnerIDParams{
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

		if err := qtx.DeleteVisitsByLessonIDAndOwnerID(ctx, db.DeleteVisitsByLessonIDAndOwnerIDParams{
			LessonID: lessonID,
			OwnerID:  ownerID,
		}); err != nil {
			return err
		}

		return qtx.DeleteLessonByIDAndOwnerID(ctx, db.DeleteLessonByIDAndOwnerIDParams{
			ID:      lessonID,
			OwnerID: ownerID,
		})
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
