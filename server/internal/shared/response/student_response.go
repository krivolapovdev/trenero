package response

import (
	"time"

	"github.com/google/uuid"
	"github.com/krivolapovdev/trenerio/internal/shared/types"
)

// @name StudentResponse
type StudentResponse struct {
	ID        uuid.UUID   `json:"id" binding:"required" format:"uuid"`
	FullName  string      `json:"fullName" binding:"required"`
	Birthdate *types.Date `json:"birthdate,omitempty" swaggertype:"string" format:"date"`
	Phone     *string     `json:"phone,omitempty"`
	Note      *string     `json:"note,omitempty"`
	CreatedAt time.Time   `json:"createdAt" binding:"required" format:"date-time"`
	Free      bool        `json:"free" binding:"required"`
}
