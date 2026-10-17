package request

import (
	"github.com/google/uuid"
)

// @name CreateGroupRequest
type CreateGroupRequest struct {
	Name         string      `json:"name" binding:"required,max=255" validate:"required,max=255"`
	DefaultPrice *float64    `json:"defaultPrice" binding:"omitempty,gt=0" validate:"omitempty,gt=0"`
	Note         *string     `json:"note" binding:"omitempty,max=255" validate:"omitempty,max=255"`
	StudentIds   []uuid.UUID `json:"studentIds"`
}
