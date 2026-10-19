package transaction

import (
	"time"

	"github.com/krivolapovdev/trenerio/internal/shared/clock"
)

// MaxPaidUntil extracts the latest PaidUntil date from a list of transactions.
// Transactions without PaymentDetails are ignored.
// If no valid payment details are found, nil is returned.
func MaxPaidUntil(payments []TransactionResponse) *time.Time {
	var maxPaidUntil *time.Time
	for _, p := range payments {
		if p.PaymentDetails != nil {
			pu := p.PaymentDetails.PaidUntil
			if maxPaidUntil == nil || pu.After(*maxPaidUntil) {
				t := pu
				maxPaidUntil = &t
			}
		}
	}
	return maxPaidUntil
}

func IsPaidUntilBeforeDate(paidUntil, date time.Time) bool {
	paidUntilEnd := clock.EndOfDay(paidUntil)
	dateStart := clock.StartOfDay(date)

	if paidUntilEnd.Before(dateStart) {
		paidUntilEndUTC := clock.EndOfDay(paidUntil.UTC())
		dateStartUTC := clock.StartOfDay(date.UTC())
		return paidUntilEndUTC.Before(dateStartUTC)
	}

	return false
}

func IsSubscriptionActive(maxPaidUntil *time.Time, referenceDate time.Time) bool {
	if maxPaidUntil == nil {
		return false
	}
	return !IsPaidUntilBeforeDate(*maxPaidUntil, referenceDate)
}
