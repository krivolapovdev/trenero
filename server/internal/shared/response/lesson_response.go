package response

import (
	"time"

	"github.com/google/uuid"
)

// @name LessonResponse
type LessonResponse struct {
	ID        uuid.UUID  `json:"id" binding:"required" format:"uuid"`
	Date      time.Time  `json:"date" binding:"required" format:"date-time"`
	CreatedAt time.Time  `json:"createdAt" binding:"required" format:"date-time"`
	GroupID   *uuid.UUID `json:"groupId,omitempty" format:"uuid"`
}

// @name LessonDetailsResponse
type LessonDetailsResponse struct {
	ID            uuid.UUID         `json:"id" binding:"required" format:"uuid"`
	Date          time.Time         `json:"date" binding:"required" format:"date-time"`
	CreatedAt     time.Time         `json:"createdAt" binding:"required" format:"date-time"`
	GroupID       *uuid.UUID        `json:"groupId,omitempty" format:"uuid"`
	StudentVisits []VisitResponse   `json:"studentVisits" binding:"required"`
	Students      []StudentResponse `json:"students" binding:"required"`
}
