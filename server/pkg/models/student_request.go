package models

import (
	"time"

	"github.com/krivolapovdev/trenerio/pkg/types"
)

// @name CreateStudentRequest
type CreateStudentRequest struct {
	FullName  string      `json:"fullName" binding:"required,max=255" validate:"required,max=255"`
	Birthdate *types.Date `json:"birthdate,omitempty" swaggertype:"string" format:"date"`
	Phone     *string     `json:"phone,omitempty" binding:"omitempty,max=15" validate:"omitempty,max=15"`
	Note      *string     `json:"note,omitempty" binding:"omitempty,max=255" validate:"omitempty,max=255"`
	Free      bool        `json:"free" validate:"required"`
}

// @name CreateStudentPaymentRequest
type CreateStudentPaymentRequest struct {
	Amount    float64   `json:"amount" binding:"required,gt=0" validate:"required,gt=0"`
	Date      time.Time `json:"date" binding:"required" validate:"required" format:"date-time"`
	PaidUntil time.Time `json:"paidUntil" binding:"required" validate:"required" format:"date-time"`
}
