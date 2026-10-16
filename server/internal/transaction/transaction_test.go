package transaction

import (
	"context"
	"testing"
	"time"

	"github.com/google/uuid"
	pkgerrors "github.com/krivolapovdev/trenerio/pkg/errors"
	"github.com/krivolapovdev/trenerio/pkg/models"
	"github.com/krivolapovdev/trenerio/pkg/types"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestParseTime(t *testing.T) {
	// RFC3339
	t1, err := parseTime("2026-10-17T15:04:05Z")
	require.NoError(t, err)
	assert.Equal(t, 2026, t1.Year())

	// RFC3339Nano
	t2, err := parseTime("2026-10-17T15:04:05.123456789Z")
	require.NoError(t, err)
	assert.Equal(t, 2026, t2.Year())

	// DateOnly
	t3, err := parseTime("2026-10-17")
	require.NoError(t, err)
	assert.Equal(t, 17, t3.Day())

	// time.Time type
	now := time.Now()
	t4, err := parseTime(now)
	require.NoError(t, err)
	assert.Equal(t, now, t4)

	// Invalid string
	_, err = parseTime("invalid-date")
	require.Error(t, err)

	// Unsupported type
	_, err = parseTime(12345)
	require.Error(t, err)
}

func TestCreateTransaction_Validation(t *testing.T) {
	svc := NewService(nil, nil, nil, nil)
	ctx := context.Background()
	ownerID := uuid.New()

	// Amount <= 0
	_, err := svc.CreateTransaction(ctx, models.CreateTransactionRequest{
		Amount: 0,
		Type:   types.TransactionTypeIncome,
		Date:   time.Now(),
	}, ownerID)
	require.Error(t, err)
	var badReq *pkgerrors.BadRequestError
	require.ErrorAs(t, err, &badReq)
	assert.Equal(t, "amount must be greater than 0", badReq.Message)

	// Nil student ID in payment details
	_, err = svc.CreateTransaction(ctx, models.CreateTransactionRequest{
		Amount: 100,
		Type:   types.TransactionTypeIncome,
		Date:   time.Now(),
		PaymentDetails: &models.CreateStudentPaymentDetailsRequest{
			StudentID: uuid.Nil,
			PaidUntil: time.Now(),
		},
	}, ownerID)
	require.Error(t, err)
	require.ErrorAs(t, err, &badReq)
	assert.Contains(t, badReq.Message, "studentId must not be null")

	// paidUntil before Date
	date := time.Date(2026, 10, 20, 0, 0, 0, 0, time.UTC)
	paidUntil := time.Date(2026, 10, 10, 0, 0, 0, 0, time.UTC)
	_, err = svc.CreateTransaction(ctx, models.CreateTransactionRequest{
		Amount: 100,
		Type:   types.TransactionTypeIncome,
		Date:   date,
		PaymentDetails: &models.CreateStudentPaymentDetailsRequest{
			StudentID: uuid.New(),
			PaidUntil: paidUntil,
		},
	}, ownerID)
	require.Error(t, err)
	require.ErrorAs(t, err, &badReq)
	assert.Contains(t, badReq.Message, "paidUntil must not be before")
}

func TestCreateStudentPayment_Validation(t *testing.T) {
	svc := NewService(nil, nil, nil, nil)
	ctx := context.Background()
	ownerID := uuid.New()
	studentID := uuid.New()

	date := time.Date(2026, 10, 20, 0, 0, 0, 0, time.UTC)
	paidUntil := time.Date(2026, 10, 15, 0, 0, 0, 0, time.UTC)

	_, err := svc.CreateStudentPayment(ctx, studentID, 100, date, paidUntil, ownerID)
	require.Error(t, err)
	var badReq *pkgerrors.BadRequestError
	require.ErrorAs(t, err, &badReq)
	assert.Contains(t, badReq.Message, "paidUntil must not be before")
}

func TestGetPaginatedTransactions_InvalidPageSize(t *testing.T) {
	svc := NewService(nil, nil, nil, nil)
	ctx := context.Background()

	_, err := svc.GetPaginatedTransactions(ctx, 1, 0, uuid.New())
	require.Error(t, err)
	var badReq *pkgerrors.BadRequestError
	require.ErrorAs(t, err, &badReq)
	assert.Contains(t, badReq.Message, "size must be at least 1")
}
