package request

import (
	"time"

	"github.com/google/uuid"
)

// @name CreateRosterRequest
type CreateRosterRequest struct {
	Name       string      `json:"name" binding:"required,max=255"`
	RosterDate *time.Time  `json:"rosterDate,omitempty" format:"date-time"`
	Note       *string     `json:"note,omitempty" binding:"omitempty,max=255"`
	StudentIds []uuid.UUID `json:"studentIds,omitempty"`
}

// @name AddRosterStudentsRequest
type AddRosterStudentsRequest struct {
	StudentIds []uuid.UUID `json:"studentIds" binding:"required"`
}
