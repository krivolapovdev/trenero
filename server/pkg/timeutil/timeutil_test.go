package timeutil

import (
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
)

func TestIsPaidUntilBeforeDate(t *testing.T) {
	utcPlus3 := time.FixedZone("MSK", 3*3600)
	utcMinus5 := time.FixedZone("EST", -5*3600)

	t.Run("SameDaySameTimezone_Valid", func(t *testing.T) {
		date := time.Date(2026, 10, 17, 15, 30, 0, 0, time.UTC)
		paidUntil := time.Date(2026, 10, 17, 0, 0, 0, 0, time.UTC)
		assert.False(t, IsPaidUntilBeforeDate(paidUntil, date))
	})

	t.Run("FutureDate_Valid", func(t *testing.T) {
		date := time.Date(2026, 10, 17, 15, 30, 0, 0, time.UTC)
		paidUntil := time.Date(2026, 11, 17, 0, 0, 0, 0, time.UTC)
		assert.False(t, IsPaidUntilBeforeDate(paidUntil, date))
	})

	t.Run("PastDate_Invalid", func(t *testing.T) {
		date := time.Date(2026, 10, 17, 15, 30, 0, 0, time.UTC)
		paidUntil := time.Date(2026, 10, 16, 0, 0, 0, 0, time.UTC)
		assert.True(t, IsPaidUntilBeforeDate(paidUntil, date))
	})

	t.Run("TimezoneOffsetPlusHours_SameDay_Valid", func(t *testing.T) {
		// User sends date in UTC, paidUntil with +3 hours
		date := time.Date(2026, 10, 17, 12, 0, 0, 0, time.UTC)
		paidUntil := time.Date(2026, 10, 17, 0, 0, 0, 0, utcPlus3)
		assert.False(t, IsPaidUntilBeforeDate(paidUntil, date))
	})

	t.Run("TimezoneOffsetMinusHours_SameDay_Valid", func(t *testing.T) {
		// User sends date in UTC, paidUntil with -5 hours
		date := time.Date(2026, 10, 17, 12, 0, 0, 0, time.UTC)
		paidUntil := time.Date(2026, 10, 17, 0, 0, 0, 0, utcMinus5)
		assert.False(t, IsPaidUntilBeforeDate(paidUntil, date))
	})
}

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
