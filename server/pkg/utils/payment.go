package utils

import (
	"github.com/krivolapovdev/trenerio/pkg/response"
	"time"
)

// MaxPaidUntil extracts the latest PaidUntil date from a list of transactions.
// Transactions without PaymentDetails are ignored.
// If no valid payment details are found, nil is returned.
func MaxPaidUntil(payments []response.TransactionResponse) *time.Time {
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
