package response

import (
	"time"
)

// @name PaymentMetricResponse
type PaymentMetricResponse struct {
	Date  time.Time `json:"date" format:"date-time"`
	Total float64   `json:"total"`
}
