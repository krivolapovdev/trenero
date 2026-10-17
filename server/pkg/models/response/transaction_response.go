package response

import (
	"time"

	"github.com/google/uuid"
	"github.com/krivolapovdev/trenerio/pkg/types"
)

// @name StudentPaymentDetailsResponse
type StudentPaymentDetailsResponse struct {
	DetailsType string    `json:"detailsType"`
	StudentID   uuid.UUID `json:"studentId" format:"uuid"`
	PaidUntil   time.Time `json:"paidUntil" format:"date-time"`
	StudentName *string   `json:"studentName,omitempty"`
}

// @name TransactionResponse
type TransactionResponse struct {
	ID             uuid.UUID                      `json:"id" format:"uuid"`
	Amount         float64                        `json:"amount"`
	Date           time.Time                      `json:"date" format:"date-time"`
	Type           types.TransactionType          `json:"type"`
	CreatedAt      time.Time                      `json:"createdAt" format:"date-time"`
	PaymentDetails *StudentPaymentDetailsResponse `json:"paymentDetails,omitempty"`
}

// @name SortObject
type SortObject struct {
	Empty    bool `json:"empty"`
	Sorted   bool `json:"sorted"`
	Unsorted bool `json:"unsorted"`
}

// @name PageableObject
type PageableObject struct {
	Offset     int64       `json:"offset"`
	PageNumber int         `json:"pageNumber"`
	PageSize   int         `json:"pageSize"`
	Paged      bool        `json:"paged"`
	Unpaged    bool        `json:"unpaged"`
	Sort       *SortObject `json:"sort,omitempty"`
}

// @name PageTransactionResponse
type PageTransactionResponse struct {
	TotalPages       int                   `json:"totalPages"`
	TotalElements    int64                 `json:"totalElements"`
	Size             int                   `json:"size"`
	Content          []TransactionResponse `json:"content"`
	Number           int                   `json:"number"`
	First            bool                  `json:"first"`
	Last             bool                  `json:"last"`
	NumberOfElements int                   `json:"numberOfElements"`
	Empty            bool                  `json:"empty"`
	Sort             *SortObject           `json:"sort,omitempty"`
	Pageable         *PageableObject       `json:"pageable,omitempty"`
}
