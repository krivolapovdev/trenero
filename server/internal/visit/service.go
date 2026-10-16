package visit

import (
	"context"
	"database/sql"

	"github.com/google/uuid"
	"github.com/krivolapovdev/trenerio/internal/db"
	"github.com/krivolapovdev/trenerio/pkg/logger"
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

func NewVisitService(queries *db.Queries, sqlDB *sql.DB) *Service {
	return NewService(queries, sqlDB)
}

func (s *Service) withTx(ctx context.Context, fn func(qtx *db.Queries) error) (err error) {
	tx, err := s.sqlDB.BeginTx(ctx, nil)
	if err != nil {
		return err
	}
	defer func() {
		if p := recover(); p != nil {
			_ = tx.Rollback()
			panic(p)
		} else if err != nil {
			_ = tx.Rollback()
		}
	}()
	qtx := s.db.WithTx(tx)
	if err = fn(qtx); err != nil {
		return err
	}
	return tx.Commit()
}

func (s *Service) GetVisitsByLessonID(ctx context.Context, lessonID, ownerID uuid.UUID) ([]VisitResponse, error) {
	logger.InfoContext(ctx, "Getting visits by lesson id", "lesson_id", lessonID.String(), "user_id", ownerID.String())
	rows, err := s.db.FindVisitsByLessonIDAndOwnerID(ctx, db.FindVisitsByLessonIDAndOwnerIDParams{
		LessonID: lessonID,
		OwnerID:  ownerID,
	})
	if err != nil {
		logger.ErrorContext(ctx, "Failed to get visits by lesson id", "lesson_id", lessonID.String(), "error", err, "user_id", ownerID.String())
		return nil, err
	}

	visits := make([]VisitResponse, 0, len(rows))
	for _, r := range rows {
		visits = append(visits, toVisitResponse(r))
	}
	logger.DebugContext(ctx, "Retrieved visits by lesson id", "lesson_id", lessonID.String(), "count", len(visits), "user_id", ownerID.String())
	return visits, nil
}

func (s *Service) GetVisitsByLessonIDs(ctx context.Context, lessonIDs []uuid.UUID, ownerID uuid.UUID) ([]VisitResponse, error) {
	logger.InfoContext(ctx, "Getting visits by lesson ids", "count", len(lessonIDs), "user_id", ownerID.String())
	if len(lessonIDs) == 0 {
		logger.DebugContext(ctx, "No lesson IDs provided to get visits", "user_id", ownerID.String())
		return []VisitResponse{}, nil
	}

	rows, err := s.db.FindVisitsByLessonIDsAndOwnerID(ctx, db.FindVisitsByLessonIDsAndOwnerIDParams{
		OwnerID: ownerID,
		Column2: lessonIDs,
	})
	if err != nil {
		logger.ErrorContext(ctx, "Failed to get visits by lesson ids", "count", len(lessonIDs), "error", err, "user_id", ownerID.String())
		return nil, err
	}

	visits := make([]VisitResponse, 0, len(rows))
	for _, r := range rows {
		visits = append(visits, toVisitResponse(r))
	}
	logger.DebugContext(ctx, "Retrieved visits by lesson ids", "count", len(visits), "user_id", ownerID.String())
	return visits, nil
}

func (s *Service) GetVisitsByStudentID(ctx context.Context, studentID, ownerID uuid.UUID) ([]VisitResponse, error) {
	logger.InfoContext(ctx, "Getting visits by student id", "student_id", studentID.String(), "user_id", ownerID.String())
	rows, err := s.db.FindVisitsByStudentIDAndOwnerID(ctx, db.FindVisitsByStudentIDAndOwnerIDParams{
		StudentID: studentID,
		OwnerID:   ownerID,
	})
	if err != nil {
		logger.ErrorContext(ctx, "Failed to get visits by student id", "student_id", studentID.String(), "error", err, "user_id", ownerID.String())
		return nil, err
	}

	visits := make([]VisitResponse, 0, len(rows))
	for _, r := range rows {
		visits = append(visits, toVisitResponse(r))
	}
	logger.DebugContext(ctx, "Retrieved visits by student id", "student_id", studentID.String(), "count", len(visits), "user_id", ownerID.String())
	return visits, nil
}

func (s *Service) GetVisitsByStudentIDs(ctx context.Context, studentIDs []uuid.UUID, ownerID uuid.UUID) (map[uuid.UUID][]VisitResponse, error) {
	logger.InfoContext(ctx, "Getting visits by student ids", "count", len(studentIDs), "user_id", ownerID.String())
	if len(studentIDs) == 0 {
		logger.DebugContext(ctx, "No student IDs provided to get visits", "user_id", ownerID.String())
		return map[uuid.UUID][]VisitResponse{}, nil
	}

	rows, err := s.db.FindVisitsByStudentIDsAndOwnerID(ctx, db.FindVisitsByStudentIDsAndOwnerIDParams{
		OwnerID: ownerID,
		Column2: studentIDs,
	})
	if err != nil {
		logger.ErrorContext(ctx, "Failed to get visits by student ids", "count", len(studentIDs), "error", err, "user_id", ownerID.String())
		return nil, err
	}

	visitsByStudent := make(map[uuid.UUID][]VisitResponse, len(studentIDs))
	for _, sid := range studentIDs {
		visitsByStudent[sid] = []VisitResponse{}
	}
	for _, r := range rows {
		visitsByStudent[r.StudentID] = append(visitsByStudent[r.StudentID], toVisitResponse(r))
	}
	logger.DebugContext(ctx, "Retrieved visits by student ids", "student_count", len(studentIDs), "total_visits", len(rows), "user_id", ownerID.String())
	return visitsByStudent, nil
}

func (s *Service) CreateVisits(ctx context.Context, lessonID uuid.UUID, studentVisits []StudentVisit, ownerID uuid.UUID) error {
	logger.InfoContext(ctx, "Creating visits", "lesson_id", lessonID.String(), "count", len(studentVisits), "user_id", ownerID.String())
	err := s.withTx(ctx, func(qtx *db.Queries) error {
		for _, sv := range studentVisits {
			_, err := qtx.CreateVisit(ctx, db.CreateVisitParams{
				OwnerID:   ownerID,
				LessonID:  lessonID,
				StudentID: sv.StudentID,
				Status:    db.VisitsModuleVisitStatus(sv.Status),
				Type:      db.VisitsModuleVisitType(sv.Type),
			})
			if err != nil {
				logger.ErrorContext(ctx, "Failed to create visit record", "lesson_id", lessonID.String(), "student_id", sv.StudentID.String(), "error", err, "user_id", ownerID.String())
				return err
			}
		}
		return nil
	})
	if err != nil {
		logger.ErrorContext(ctx, "Failed to create visits in transaction", "lesson_id", lessonID.String(), "error", err, "user_id", ownerID.String())
		return err
	}
	logger.InfoContext(ctx, "Visits created successfully", "lesson_id", lessonID.String(), "count", len(studentVisits), "user_id", ownerID.String())
	return nil
}

func (s *Service) RemoveVisitsByLessonID(ctx context.Context, lessonID, ownerID uuid.UUID) error {
	logger.InfoContext(ctx, "Removing visits by lesson id", "lesson_id", lessonID.String(), "user_id", ownerID.String())
	err := s.db.DeleteVisitsByLessonIDAndOwnerID(ctx, db.DeleteVisitsByLessonIDAndOwnerIDParams{
		LessonID: lessonID,
		OwnerID:  ownerID,
	})
	if err != nil {
		logger.ErrorContext(ctx, "Failed to remove visits by lesson id", "lesson_id", lessonID.String(), "error", err, "user_id", ownerID.String())
		return err
	}
	logger.InfoContext(ctx, "Visits removed successfully", "lesson_id", lessonID.String(), "user_id", ownerID.String())
	return nil
}

func (s *Service) UpdateVisitsByLessonID(ctx context.Context, lessonID uuid.UUID, requests []StudentVisit, ownerID uuid.UUID) error {
	logger.InfoContext(ctx, "Updating visits by lesson id", "lesson_id", lessonID.String(), "count", len(requests), "user_id", ownerID.String())
	err := s.withTx(ctx, func(qtx *db.Queries) error {
		existingVisits, err := qtx.FindVisitsByLessonIDAndOwnerID(ctx, db.FindVisitsByLessonIDAndOwnerIDParams{
			LessonID: lessonID,
			OwnerID:  ownerID,
		})
		if err != nil {
			logger.ErrorContext(ctx, "Failed to fetch existing visits for lesson update", "lesson_id", lessonID.String(), "error", err, "user_id", ownerID.String())
			return err
		}

		existingMap := make(map[uuid.UUID]db.VisitsModuleVisit, len(existingVisits))
		for _, ev := range existingVisits {
			existingMap[ev.StudentID] = ev
		}

		reqMap := make(map[uuid.UUID]StudentVisit, len(requests))
		for _, req := range requests {
			reqMap[req.StudentID] = req
		}

		deletedCount := 0
		for studentID, ev := range existingMap {
			if _, ok := reqMap[studentID]; !ok {
				if err := qtx.DeleteVisitByIDAndOwnerID(ctx, db.DeleteVisitByIDAndOwnerIDParams{
					ID:      ev.ID,
					OwnerID: ownerID,
				}); err != nil {
					logger.ErrorContext(ctx, "Failed to delete removed visit", "visit_id", ev.ID.String(), "error", err, "user_id", ownerID.String())
					return err
				}
				deletedCount++
			}
		}

		updatedCount := 0
		createdCount := 0
		for studentID, req := range reqMap {
			if ev, ok := existingMap[studentID]; ok {
				_, err := qtx.UpdateVisit(ctx, db.UpdateVisitParams{
					ID:      ev.ID,
					OwnerID: ownerID,
					Status:  db.VisitsModuleVisitStatus(req.Status),
					Type:    db.VisitsModuleVisitType(req.Type),
				})
				if err != nil {
					logger.ErrorContext(ctx, "Failed to update visit", "visit_id", ev.ID.String(), "error", err, "user_id", ownerID.String())
					return err
				}
				updatedCount++
			} else {
				_, err := qtx.CreateVisit(ctx, db.CreateVisitParams{
					OwnerID:   ownerID,
					LessonID:  lessonID,
					StudentID: req.StudentID,
					Status:    db.VisitsModuleVisitStatus(req.Status),
					Type:      db.VisitsModuleVisitType(req.Type),
				})
				if err != nil {
					logger.ErrorContext(ctx, "Failed to create new visit during update", "student_id", req.StudentID.String(), "error", err, "user_id", ownerID.String())
					return err
				}
				createdCount++
			}
		}

		logger.DebugContext(ctx, "Visits sync details", "lesson_id", lessonID.String(), "deleted", deletedCount, "updated", updatedCount, "created", createdCount, "user_id", ownerID.String())
		return nil
	})
	if err != nil {
		logger.ErrorContext(ctx, "Failed to update visits in transaction", "lesson_id", lessonID.String(), "error", err, "user_id", ownerID.String())
		return err
	}
	logger.InfoContext(ctx, "Visits updated successfully", "lesson_id", lessonID.String(), "user_id", ownerID.String())
	return nil
}

func toVisitResponse(v db.VisitsModuleVisit) VisitResponse {
	return VisitResponse{
		ID:        v.ID,
		Status:    types.VisitStatus(v.Status),
		Type:      types.VisitType(v.Type),
		LessonID:  v.LessonID,
		StudentID: v.StudentID,
		CreatedAt: v.CreatedAt,
	}
}
