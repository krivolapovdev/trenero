package models

import (
	"github.com/google/uuid"
)

// @name UserResponse
type UserResponse struct {
	ID    uuid.UUID `json:"id" format:"uuid"`
	Email string    `json:"email"`
}
