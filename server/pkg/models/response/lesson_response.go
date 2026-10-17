package response

import (
	"time"

	"github.com/google/uuid"
)

// @name LessonResponse
type LessonResponse struct {
	ID        uuid.UUID  `json:"id" format:"uuid"`
	Date      time.Time  `json:"date" format:"date-time"`
	CreatedAt time.Time  `json:"createdAt" format:"date-time"`
	GroupID   *uuid.UUID `json:"groupId,omitempty" format:"uuid"`
}

// @name LessonDetailsResponse
type LessonDetailsResponse struct {
	ID            uuid.UUID         `json:"id" format:"uuid"`
	Date          time.Time         `json:"date" format:"date-time"`
	CreatedAt     time.Time         `json:"createdAt" format:"date-time"`
	GroupID       *uuid.UUID        `json:"groupId,omitempty" format:"uuid"`
	StudentVisits []VisitResponse   `json:"studentVisits"`
	Students      []StudentResponse `json:"students"`
}
