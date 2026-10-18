package models

import (
	"time"

	"github.com/google/uuid"
	"github.com/krivolapovdev/trenerio/pkg/types"
)

// @name CreateStudentPaymentDetailsRequest
type CreateStudentPaymentDetailsRequest struct {
	DetailsType string    `json:"detailsType,omitempty"`
	StudentID   uuid.UUID `json:"studentId" binding:"required" validate:"required" format:"uuid"`
	PaidUntil   time.Time `json:"paidUntil" binding:"required" validate:"required" format:"date-time"`
}

// @name CreateTransactionRequest
type CreateTransactionRequest struct {
	Amount         float64                             `json:"amount" binding:"required,gt=0" validate:"required,gt=0"`
	Date           time.Time                           `json:"date" binding:"required" validate:"required" format:"date-time"`
	Type           types.TransactionType               `json:"type" binding:"required" validate:"required"`
	PaymentDetails *CreateStudentPaymentDetailsRequest `json:"paymentDetails,omitempty"`
}
