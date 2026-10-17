package utils

import (
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
)

func TestIsSubscriptionActive(t *testing.T) {
	utcPlus3 := time.FixedZone("MSK", 3*3600)

	t.Run("NilMaxPaidUntil_Inactive", func(t *testing.T) {
		ref := time.Date(2026, 10, 17, 15, 0, 0, 0, time.UTC)
		assert.False(t, IsSubscriptionActive(nil, ref))
	})

	t.Run("SameDayAtMidnight_Active", func(t *testing.T) {
		ref := time.Date(2026, 10, 17, 15, 0, 0, 0, time.UTC)
		paidUntil := time.Date(2026, 10, 17, 0, 0, 0, 0, time.UTC)
		assert.True(t, IsSubscriptionActive(&paidUntil, ref))
	})

	t.Run("SameDayWithTimezoneSkew_Active", func(t *testing.T) {
		ref := time.Date(2026, 10, 17, 12, 0, 0, 0, time.UTC)
		// 2026-10-17 00:00:00 +0300 is 2026-10-16 21:00:00 UTC
		paidUntil := time.Date(2026, 10, 17, 0, 0, 0, 0, utcPlus3)
		assert.True(t, IsSubscriptionActive(&paidUntil, ref))
	})

	t.Run("ExpiredYesterday_Inactive", func(t *testing.T) {
		ref := time.Date(2026, 10, 17, 10, 0, 0, 0, time.UTC)
		paidUntil := time.Date(2026, 10, 15, 23, 59, 59, 0, time.UTC)
		assert.False(t, IsSubscriptionActive(&paidUntil, ref))
	})
}
