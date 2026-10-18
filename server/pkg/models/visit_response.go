package models

import (
	"time"

	"github.com/google/uuid"
	"github.com/krivolapovdev/trenerio/pkg/types"
)

// @name VisitResponse
type VisitResponse struct {
	ID        uuid.UUID         `json:"id" format:"uuid"`
	Status    types.VisitStatus `json:"status"`
	Type      types.VisitType   `json:"type"`
	LessonID  uuid.UUID         `json:"lessonId" format:"uuid"`
	StudentID uuid.UUID         `json:"studentId" format:"uuid"`
	CreatedAt time.Time         `json:"createdAt" format:"date-time"`
}

// @name VisitWithLessonResponse
type VisitWithLessonResponse struct {
	Visit  VisitResponse  `json:"visit"`
	Lesson LessonResponse `json:"lesson"`
}
