package models

import (
	"time"

	"github.com/google/uuid"
	"github.com/krivolapovdev/trenerio/pkg/types"
)

// @name StudentResponse
type StudentResponse struct {
	ID        uuid.UUID   `json:"id" format:"uuid"`
	FullName  string      `json:"fullName"`
	Birthdate *types.Date `json:"birthdate,omitempty" swaggertype:"string" format:"date"`
	Phone     *string     `json:"phone,omitempty"`
	Note      *string     `json:"note,omitempty"`
	CreatedAt time.Time   `json:"createdAt" format:"date-time"`
	Free      bool        `json:"free"`
}

// @name StudentSummaryResponse
type StudentSummaryResponse struct {
	ID            uuid.UUID             `json:"id" format:"uuid"`
	FullName      string                `json:"fullName"`
	Birthdate     *types.Date           `json:"birthdate,omitempty" swaggertype:"string" format:"date"`
	Phone         *string               `json:"phone,omitempty"`
	Note          *string               `json:"note,omitempty"`
	CreatedAt     time.Time             `json:"createdAt" format:"date-time"`
	Free          bool                  `json:"free"`
	Statuses      []types.StudentStatus `json:"statuses"`
	StudentGroups []GroupResponse       `json:"studentGroups"`
}
