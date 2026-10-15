package visit

import (
	"context"
	"database/sql"

	"github.com/google/uuid"
	"github.com/krivolapovdev/trenerio/internal/db"
	"github.com/krivolapovdev/trenerio/pkg/logger"
	"github.com/krivolapovdev/trenerio/pkg/types"
)

type VisitService struct {
	db    *db.Queries
	sqlDB *sql.DB
}

func NewVisitService(queries *db.Queries, sqlDB *sql.DB) *VisitService {
	return &VisitService{
		db:    queries,
		sqlDB: sqlDB,
	}
}

func (s *VisitService) GetVisitsByLessonID(ctx context.Context, lessonID, ownerID uuid.UUID) ([]VisitResponse, error) {
	logger.InfoContext(ctx, "Getting visits by lesson id", "lesson_id", lessonID.String(), "user_id", ownerID.String())
	rows, err := s.db.FindVisitsByLessonIDAndOwnerID(ctx, db.FindVisitsByLessonIDAndOwnerIDParams{
		LessonID: lessonID,
		OwnerID:  ownerID,
	})
	if err != nil {
		return nil, err
	}
	res := make([]VisitResponse, 0, len(rows))
	for _, r := range rows {
		res = append(res, toVisitResponse(r))
	}
	return res, nil
}

func (s *VisitService) GetVisitsByLessonIDs(ctx context.Context, lessonIDs []uuid.UUID, ownerID uuid.UUID) ([]VisitResponse, error) {
	logger.InfoContext(ctx, "Getting visits by lesson ids", "count", len(lessonIDs), "user_id", ownerID.String())
	if len(lessonIDs) == 0 {
		return []VisitResponse{}, nil
	}
	rows, err := s.db.FindVisitsByLessonIDsAndOwnerID(ctx, db.FindVisitsByLessonIDsAndOwnerIDParams{
		OwnerID: ownerID,
		Column2: lessonIDs,
	})
	if err != nil {
		return nil, err
	}
	res := make([]VisitResponse, 0, len(rows))
	for _, r := range rows {
		res = append(res, toVisitResponse(r))
	}
	return res, nil
}

func (s *VisitService) GetVisitsByStudentID(ctx context.Context, studentID, ownerID uuid.UUID) ([]VisitResponse, error) {
	logger.InfoContext(ctx, "Getting visits by student id", "student_id", studentID.String(), "user_id", ownerID.String())
	rows, err := s.db.FindVisitsByStudentIDAndOwnerID(ctx, db.FindVisitsByStudentIDAndOwnerIDParams{
		StudentID: studentID,
		OwnerID:   ownerID,
	})
	if err != nil {
		return nil, err
	}
	res := make([]VisitResponse, 0, len(rows))
	for _, r := range rows {
		res = append(res, toVisitResponse(r))
	}
	return res, nil
}

func (s *VisitService) GetVisitsByStudentIDs(ctx context.Context, studentIDs []uuid.UUID, ownerID uuid.UUID) (map[uuid.UUID][]VisitResponse, error) {
	logger.InfoContext(ctx, "Getting visits by student ids", "count", len(studentIDs), "user_id", ownerID.String())
	if len(studentIDs) == 0 {
		return map[uuid.UUID][]VisitResponse{}, nil
	}
	rows, err := s.db.FindVisitsByStudentIDsAndOwnerID(ctx, db.FindVisitsByStudentIDsAndOwnerIDParams{
		OwnerID: ownerID,
		Column2: studentIDs,
	})
	if err != nil {
		return nil, err
	}
	res := make(map[uuid.UUID][]VisitResponse)
	for _, sid := range studentIDs {
		res[sid] = []VisitResponse{}
	}
	for _, r := range rows {
		res[r.StudentID] = append(res[r.StudentID], toVisitResponse(r))
	}
	return res, nil
}

func (s *VisitService) withTx(ctx context.Context, fn func(qtx *db.Queries) error) error {
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

func (s *VisitService) CreateVisits(ctx context.Context, lessonID uuid.UUID, studentVisits []StudentVisit, ownerID uuid.UUID) error {
	logger.InfoContext(ctx, "Creating visits", "lesson_id", lessonID.String(), "count", len(studentVisits), "user_id", ownerID.String())
	return s.withTx(ctx, func(qtx *db.Queries) error {
		for _, sv := range studentVisits {
			_, err := qtx.CreateVisit(ctx, db.CreateVisitParams{
				OwnerID:   ownerID,
				LessonID:  lessonID,
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
}

func (s *VisitService) RemoveVisitsByLessonID(ctx context.Context, lessonID, ownerID uuid.UUID) error {
	logger.InfoContext(ctx, "Removing visits by lesson id", "lesson_id", lessonID.String(), "user_id", ownerID.String())
	return s.db.DeleteVisitsByLessonIDAndOwnerID(ctx, db.DeleteVisitsByLessonIDAndOwnerIDParams{
		LessonID: lessonID,
		OwnerID:  ownerID,
	})
}

func (s *VisitService) UpdateVisitsByLessonID(ctx context.Context, lessonID uuid.UUID, requests []StudentVisit, ownerID uuid.UUID) error {
	logger.InfoContext(ctx, "Updating visits by lesson id", "lesson_id", lessonID.String(), "count", len(requests), "user_id", ownerID.String())
	return s.withTx(ctx, func(qtx *db.Queries) error {
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

		reqMap := make(map[uuid.UUID]StudentVisit)
		for _, req := range requests {
			reqMap[req.StudentID] = req
		}

		for studentID, ev := range existingMap {
			if _, ok := reqMap[studentID]; !ok {
				if err := qtx.DeleteVisitByIDAndOwnerID(ctx, db.DeleteVisitByIDAndOwnerIDParams{
					ID:      ev.ID,
					OwnerID: ownerID,
				}); err != nil {
					return err
				}
			}
		}

		for studentID, req := range reqMap {
			if ev, ok := existingMap[studentID]; ok {
				_, err := qtx.UpdateVisit(ctx, db.UpdateVisitParams{
					ID:      ev.ID,
					OwnerID: ownerID,
					Status:  db.VisitsModuleVisitStatus(req.Status),
					Type:    db.VisitsModuleVisitType(req.Type),
				})
				if err != nil {
					return err
				}
			} else {
				_, err := qtx.CreateVisit(ctx, db.CreateVisitParams{
					OwnerID:   ownerID,
					LessonID:  lessonID,
					StudentID: req.StudentID,
					Status:    db.VisitsModuleVisitStatus(req.Status),
					Type:      db.VisitsModuleVisitType(req.Type),
				})
				if err != nil {
					return err
				}
			}
		}

		return nil
	})
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
