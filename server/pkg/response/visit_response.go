package response

import (
	"time"

	"github.com/google/uuid"
	"github.com/krivolapovdev/trenerio/pkg/types"
)

// @name VisitResponse
type VisitResponse struct {
	ID        uuid.UUID         `json:"id" binding:"required" format:"uuid"`
	Status    types.VisitStatus `json:"status" binding:"required"`
	Type      types.VisitType   `json:"type" binding:"required"`
	LessonID  uuid.UUID         `json:"lessonId" binding:"required" format:"uuid"`
	StudentID uuid.UUID         `json:"studentId" binding:"required" format:"uuid"`
	CreatedAt time.Time         `json:"createdAt" binding:"required" format:"date-time"`
}

// @name VisitWithLessonResponse
type VisitWithLessonResponse struct {
	Visit  VisitResponse  `json:"visit" binding:"required"`
	Lesson LessonResponse `json:"lesson" binding:"required"`
}
