package utils

import (
	"time"
)

func StartOfDay(t time.Time) time.Time {
	return time.Date(t.Year(), t.Month(), t.Day(), 0, 0, 0, 0, t.Location())
}

func EndOfDay(t time.Time) time.Time {
	return time.Date(t.Year(), t.Month(), t.Day(), 23, 59, 59, 999999999, t.Location())
}

func IsPaidUntilBeforeDate(paidUntil, date time.Time) bool {
	paidUntilEnd := EndOfDay(paidUntil)
	dateStart := StartOfDay(date)

	if paidUntilEnd.Before(dateStart) {
		paidUntilEndUTC := EndOfDay(paidUntil.UTC())
		dateStartUTC := StartOfDay(date.UTC())
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
