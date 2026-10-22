package transaction

import (
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/krivolapovdev/trenerio/internal/db"
	"github.com/stretchr/testify/assert"
)

func TestToTransactionResponse(t *testing.T) {
	txID := uuid.New()
	now := time.Now()
	date := time.Date(2026, 10, 20, 14, 0, 0, 0, time.UTC)

	tx := db.PaymentsModuleTransaction{
		ID:        txID,
		Amount:    "125.75",
		Date:      date,
		Type:      db.PaymentsModuleTransactionTypeINCOME,
		CreatedAt: now,
	}

	studentID := uuid.New()
	paidUntil := time.Date(2026, 11, 20, 0, 0, 0, 0, time.UTC)
	details := &StudentPaymentDetailsResponse{
		DetailsType: DetailsTypeStudent,
		StudentID:   studentID,
		PaidUntil:   paidUntil,
	}

	resp := toTransactionResponse(tx, details)
	assert.Equal(t, txID, resp.ID)
	assert.Equal(t, 125.75, resp.Amount)
	assert.Equal(t, date, resp.Date)
	assert.Equal(t, TransactionTypeIncome, resp.Type)
	assert.Equal(t, now, resp.CreatedAt)
	assert.Equal(t, details, resp.PaymentDetails)
}
