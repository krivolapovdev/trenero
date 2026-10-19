package transaction

import (
	"time"

	"github.com/google/uuid"
)

// @name CreateStudentPaymentDetailsRequest
type CreateStudentPaymentDetailsRequest struct {
	DetailsType string    `json:"detailsType,omitempty"`
	StudentID   uuid.UUID `json:"studentId" binding:"required" format:"uuid"`
	PaidUntil   time.Time `json:"paidUntil" binding:"required" format:"date-time"`
}

// @name CreateTransactionRequest
type CreateTransactionRequest struct {
	Amount         float64                             `json:"amount" binding:"required,gt=0"`
	Date           time.Time                           `json:"date" binding:"required" format:"date-time"`
	Type           TransactionType                     `json:"type" binding:"required"`
	PaymentDetails *CreateStudentPaymentDetailsRequest `json:"paymentDetails,omitempty"`
}
