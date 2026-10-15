package metric

import (
	"context"
	"testing"
	"time"

	"github.com/google/uuid"
	pkgerrors "github.com/krivolapovdev/trenerio/pkg/errors"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestMetricService_InvalidDateRange(t *testing.T) {
	service := NewMetricService(nil)

	startDate := time.Date(2026, 10, 15, 0, 0, 0, 0, time.UTC)
	endDate := time.Date(2026, 10, 10, 0, 0, 0, 0, time.UTC)

	_, err := service.GetPaymentStatistics(context.Background(), "MONTH", startDate, endDate, uuid.New())
	require.Error(t, err)

	badReq, ok := err.(*pkgerrors.BadRequestError)
	require.True(t, ok)
	assert.Equal(t, "endDate must not be before startDate", badReq.Message)
}
