package response

import (
	"time"

	"github.com/google/uuid"
)

// @name GroupResponse
type GroupResponse struct {
	ID           uuid.UUID `json:"id" binding:"required" format:"uuid"`
	Name         string    `json:"name" binding:"required"`
	DefaultPrice *float64  `json:"defaultPrice,omitempty"`
	Note         *string   `json:"note,omitempty"`
	CreatedAt    time.Time `json:"createdAt" binding:"required" format:"date-time"`
}

// @name GroupStudentResponse
type GroupStudentResponse struct {
	ID        uuid.UUID `json:"id" format:"uuid"`
	GroupID   uuid.UUID `json:"groupId" format:"uuid"`
	StudentID uuid.UUID `json:"studentId" format:"uuid"`
}

// @name GroupSummaryResponse
type GroupSummaryResponse struct {
	ID              uuid.UUID `json:"id" binding:"required" format:"uuid"`
	Name            string    `json:"name" binding:"required"`
	DefaultPrice    *float64  `json:"defaultPrice,omitempty"`
	Note            *string   `json:"note,omitempty"`
	CreatedAt       time.Time `json:"createdAt" binding:"required" format:"date-time"`
	CountOfStudents int64     `json:"countOfStudents"`
}
