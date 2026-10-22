package response

import (
	"time"

	"github.com/google/uuid"
)

// @name RosterResponse
type RosterResponse struct {
	ID              uuid.UUID         `json:"id" binding:"required" format:"uuid"`
	Name            string            `json:"name" binding:"required"`
	RosterDate      *time.Time        `json:"rosterDate,omitempty" format:"date-time"`
	Note            *string           `json:"note,omitempty"`
	CreatedAt       time.Time         `json:"createdAt" binding:"required" format:"date-time"`
	CountOfStudents int64             `json:"countOfStudents"`
	Students        []StudentResponse `json:"students,omitempty"`
}

// @name ParticipantResponse
type ParticipantResponse struct {
	ID        uuid.UUID `json:"id" format:"uuid"`
	RosterID  uuid.UUID `json:"rosterId" format:"uuid"`
	StudentID uuid.UUID `json:"studentId" format:"uuid"`
	Note      *string   `json:"note,omitempty"`
}
