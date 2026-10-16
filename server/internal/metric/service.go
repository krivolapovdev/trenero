package metric

import (
	"context"
	"strings"
	"time"

	"github.com/google/uuid"
	pkgerrors "github.com/krivolapovdev/trenerio/pkg/errors"
	"github.com/krivolapovdev/trenerio/pkg/logger"
	"github.com/krivolapovdev/trenerio/pkg/models"
	"github.com/krivolapovdev/trenerio/pkg/types"
)

type FetchTransactionsBetweenFunc func(ctx context.Context, startDate, endDate time.Time, ownerID uuid.UUID) ([]models.TransactionResponse, error)

type Service struct {
	fetchTransactions FetchTransactionsBetweenFunc
}

func NewService(fetchTransactions FetchTransactionsBetweenFunc) *Service {
	return &Service{
		fetchTransactions: fetchTransactions,
	}
}

func (s *Service) GetPaymentStatistics(ctx context.Context, scopeStr string, startDate, endDate time.Time, ownerID uuid.UUID) ([]models.PaymentMetricResponse, error) {
	if endDate.Before(startDate) {
		return nil, &pkgerrors.BadRequestError{
			Message: "endDate must not be before startDate",
		}
	}

	scope := strings.ToUpper(strings.TrimSpace(scopeStr))
	if scope == "" {
		scope = "MONTH"
	}

	logger.InfoContext(ctx, "Getting payment statistics",
		"scope", scope,
		"start_date", startDate.Format(time.RFC3339),
		"end_date", endDate.Format(time.RFC3339),
		"user_id", ownerID.String(),
	)

	loc := startDate.Location()
	truncate := func(t time.Time) time.Time {
		t = t.In(loc)
		switch scope {
		case "WEEK":
			weekday := int(t.Weekday())
			if weekday == 0 {
				weekday = 7
			}
			daysToMonday := weekday - 1
			d := t.AddDate(0, 0, -daysToMonday)
			return time.Date(d.Year(), d.Month(), d.Day(), 0, 0, 0, 0, loc)
		case "YEAR":
			return time.Date(t.Year(), 1, 1, 0, 0, 0, 0, loc)
		default:
			return time.Date(t.Year(), t.Month(), 1, 0, 0, 0, 0, loc)
		}
	}
	next := func(t time.Time) time.Time {
		switch scope {
		case "WEEK":
			return t.AddDate(0, 0, 7)
		case "YEAR":
			return t.AddDate(1, 0, 0)
		default:
			return t.AddDate(0, 1, 0)
		}
	}
	rows, err := s.fetchTransactions(ctx, startDate, endDate, ownerID)
	if err != nil {
		return nil, err
	}

	totalsByBucket := make(map[int64]float64)
	for _, r := range rows {
		bucket := truncate(r.Date)
		amt := r.Amount
		if r.Type == types.TransactionTypeIncome {
			totalsByBucket[bucket.Unix()] += amt
		} else {
			totalsByBucket[bucket.Unix()] -= amt
		}
	}
	res := make([]models.PaymentMetricResponse, 0)
	current := truncate(startDate)
	limit := truncate(endDate)
	for !current.After(limit) {
		amount := totalsByBucket[current.Unix()]
		res = append(res, models.PaymentMetricResponse{
			Date:  current,
			Total: amount,
		})
		current = next(current)
	}
	return res, nil
}
