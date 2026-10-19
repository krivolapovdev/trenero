package visit

import (
	"time"

	"github.com/google/uuid"
)

// @name VisitResponse
type VisitResponse struct {
	ID        uuid.UUID   `json:"id" binding:"required" format:"uuid"`
	Status    VisitStatus `json:"status" binding:"required"`
	Type      VisitType   `json:"type" binding:"required"`
	LessonID  uuid.UUID   `json:"lessonId" binding:"required" format:"uuid"`
	StudentID uuid.UUID   `json:"studentId" binding:"required" format:"uuid"`
	CreatedAt time.Time   `json:"createdAt" binding:"required" format:"date-time"`
}

// FindVisitByLessonID finds a visit associated with the given lesson ID.
func FindVisitByLessonID(visits []VisitResponse, lessonID uuid.UUID) *VisitResponse {
	for i := range visits {
		if visits[i].LessonID == lessonID {
			return &visits[i]
		}
	}
	return nil
}
