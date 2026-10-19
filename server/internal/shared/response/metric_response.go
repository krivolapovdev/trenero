package response

import (
	"time"
)

// @name PaymentMetricResponse
type PaymentMetricResponse struct {
	Date  time.Time `json:"date" binding:"required" format:"date-time"`
	Total float64   `json:"total" binding:"required"`
}
