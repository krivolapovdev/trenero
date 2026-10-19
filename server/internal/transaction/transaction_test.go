package transaction

import (
	"context"
	"testing"
	"time"

	"github.com/google/uuid"
	pkgerrors "github.com/krivolapovdev/trenerio/internal/shared/errors"
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

func TestGetPaginatedTransactions_InvalidPageSize(t *testing.T) {
	svc := NewService(nil, nil, nil)
	ctx := context.Background()

	_, err := svc.GetPaginatedTransactions(ctx, 1, 0, uuid.New())
	require.Error(t, err)
	var badReq *pkgerrors.BadRequestError
	require.ErrorAs(t, err, &badReq)
	assert.Contains(t, badReq.Message, "size must be at least 1")
}
