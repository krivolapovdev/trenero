package utils

import (
	"testing"
	"time"

	"github.com/krivolapovdev/trenerio/pkg/models"
	"github.com/stretchr/testify/assert"
)

func TestMaxPaidUntil(t *testing.T) {
	t.Run("EmptyList_ReturnsNil", func(t *testing.T) {
		assert.Nil(t, MaxPaidUntil(nil))
		assert.Nil(t, MaxPaidUntil([]models.TransactionResponse{}))
	})

	t.Run("NoPaymentDetails_ReturnsNil", func(t *testing.T) {
		txs := []models.TransactionResponse{
			{PaymentDetails: nil},
			{PaymentDetails: nil},
		}
		assert.Nil(t, MaxPaidUntil(txs))
	})

	t.Run("MultiplePayments_ReturnsLatest", func(t *testing.T) {
		t1 := time.Date(2026, 1, 15, 0, 0, 0, 0, time.UTC)
		t2 := time.Date(2026, 3, 1, 0, 0, 0, 0, time.UTC)
		t3 := time.Date(2026, 2, 20, 0, 0, 0, 0, time.UTC)

		txs := []models.TransactionResponse{
			{PaymentDetails: &models.StudentPaymentDetailsResponse{PaidUntil: t1}},
			{PaymentDetails: nil},
			{PaymentDetails: &models.StudentPaymentDetailsResponse{PaidUntil: t2}},
			{PaymentDetails: &models.StudentPaymentDetailsResponse{PaidUntil: t3}},
		}

		latest := MaxPaidUntil(txs)
		assert.NotNil(t, latest)
		assert.Equal(t, t2, *latest)
	})
}
