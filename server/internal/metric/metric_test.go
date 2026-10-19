package metric

import (
	"context"
	"github.com/krivolapovdev/trenerio/pkg/response"
	"testing"
	"time"

	"github.com/google/uuid"
	pkgerrors "github.com/krivolapovdev/trenerio/pkg/errors"
	"github.com/krivolapovdev/trenerio/pkg/types"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestMetricService_InvalidDateRange(t *testing.T) {
	service := NewService(nil)

	startDate := time.Date(2026, 10, 15, 0, 0, 0, 0, time.UTC)
	endDate := time.Date(2026, 10, 10, 0, 0, 0, 0, time.UTC)

	_, err := service.GetPaymentStatistics(context.Background(), "MONTH", startDate, endDate, uuid.New())
	require.Error(t, err)

	badReq, ok := err.(*pkgerrors.BadRequestError)
	require.True(t, ok)
	assert.Equal(t, "endDate must not be before startDate", badReq.Message)
}

func TestMetricScopeStrategy_Week(t *testing.T) {
	strategy := weekStrategy{}
	loc := time.UTC

	// Wednesday 2026-10-14 -> Monday 2026-10-12
	date := time.Date(2026, 10, 14, 15, 30, 0, 0, loc)
	truncated := strategy.Truncate(date, loc)
	assert.Equal(t, time.Date(2026, 10, 12, 0, 0, 0, 0, loc), truncated)

	// Sunday 2026-10-18 -> Monday 2026-10-12
	sunday := time.Date(2026, 10, 18, 23, 59, 59, 0, loc)
	assert.Equal(t, time.Date(2026, 10, 12, 0, 0, 0, 0, loc), strategy.Truncate(sunday, loc))

	// Next
	next := strategy.Next(truncated)
	assert.Equal(t, time.Date(2026, 10, 19, 0, 0, 0, 0, loc), next)
}

func TestMetricScopeStrategy_Month(t *testing.T) {
	strategy := monthStrategy{}
	loc := time.UTC

	date := time.Date(2026, 10, 14, 15, 30, 0, 0, loc)
	truncated := strategy.Truncate(date, loc)
	assert.Equal(t, time.Date(2026, 10, 1, 0, 0, 0, 0, loc), truncated)

	next := strategy.Next(truncated)
	assert.Equal(t, time.Date(2026, 11, 1, 0, 0, 0, 0, loc), next)
}

func TestMetricScopeStrategy_Year(t *testing.T) {
	strategy := yearStrategy{}
	loc := time.UTC

	date := time.Date(2026, 10, 14, 15, 30, 0, 0, loc)
	truncated := strategy.Truncate(date, loc)
	assert.Equal(t, time.Date(2026, 1, 1, 0, 0, 0, 0, loc), truncated)

	next := strategy.Next(truncated)
	assert.Equal(t, time.Date(2027, 1, 1, 0, 0, 0, 0, loc), next)
}

func TestMetricService_Calculation(t *testing.T) {
	startDate := time.Date(2026, 1, 1, 0, 0, 0, 0, time.UTC)
	endDate := time.Date(2026, 3, 31, 0, 0, 0, 0, time.UTC)
	ownerID := uuid.New()

	mockFetch := func(ctx context.Context, s, e time.Time, o uuid.UUID) ([]response.TransactionResponse, error) {
		return []response.TransactionResponse{
			{
				Amount: 1000,
				Date:   time.Date(2026, 1, 15, 12, 0, 0, 0, time.UTC),
				Type:   types.TransactionTypeIncome,
			},
			{
				Amount: 200,
				Date:   time.Date(2026, 1, 20, 12, 0, 0, 0, time.UTC),
				Type:   types.TransactionTypeExpense,
			},
			{
				Amount: 500,
				Date:   time.Date(2026, 3, 5, 12, 0, 0, 0, time.UTC),
				Type:   types.TransactionTypeIncome,
			},
		}, nil
	}

	service := NewService(mockFetch)
	metrics, err := service.GetPaymentStatistics(context.Background(), "MONTH", startDate, endDate, ownerID)
	require.NoError(t, err)

	// Expect 3 buckets: Jan (800), Feb (0), Mar (500)
	require.Len(t, metrics, 3)
	assert.Equal(t, 800.0, metrics[0].Total)
	assert.Equal(t, 0.0, metrics[1].Total)
	assert.Equal(t, 500.0, metrics[2].Total)
}
