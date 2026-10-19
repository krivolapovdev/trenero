package student

import (
	"time"

	"github.com/google/uuid"
	"github.com/krivolapovdev/trenerio/internal/shared/response"
	"github.com/krivolapovdev/trenerio/internal/shared/types"
)

// @name StudentSummaryResponse
type StudentSummaryResponse struct {
	ID            uuid.UUID                `json:"id" binding:"required" format:"uuid"`
	FullName      string                   `json:"fullName" binding:"required"`
	Birthdate     *types.Date              `json:"birthdate,omitempty" swaggertype:"string" format:"date"`
	Phone         *string                  `json:"phone,omitempty"`
	Note          *string                  `json:"note,omitempty"`
	CreatedAt     time.Time                `json:"createdAt" binding:"required" format:"date-time"`
	Free          bool                     `json:"free" binding:"required"`
	Statuses      []StudentStatus          `json:"statuses" binding:"required"`
	StudentGroups []response.GroupResponse `json:"studentGroups"`
}
