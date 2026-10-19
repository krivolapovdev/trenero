package response

import (
	"github.com/google/uuid"
)

// @name UserResponse
type UserResponse struct {
	ID    uuid.UUID `json:"id" binding:"required" format:"uuid"`
	Email string    `json:"email" binding:"required"`
}
