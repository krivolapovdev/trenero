package metric

import (
	"context"
	"strings"
	"time"

	"github.com/google/uuid"
	pkgerrors "github.com/krivolapovdev/trenerio/internal/shared/errors"
	"github.com/krivolapovdev/trenerio/internal/shared/logger"
	"github.com/krivolapovdev/trenerio/internal/shared/response"
	"github.com/krivolapovdev/trenerio/internal/transaction"
)

type TransactionProvider interface {
	GetTransactionsBetween(ctx context.Context, startDate, endDate time.Time, ownerID uuid.UUID) ([]response.TransactionResponse, error)
}

type ScopeStrategy interface {
	Truncate(t time.Time, loc *time.Location) time.Time
	Next(t time.Time) time.Time
}

type weekStrategy struct{}

func (weekStrategy) Truncate(t time.Time, loc *time.Location) time.Time {
	t = t.In(loc)
	weekday := int(t.Weekday())
	if weekday == 0 {
		weekday = 7
	}
	daysToMonday := weekday - 1
	d := t.AddDate(0, 0, -daysToMonday)
	return time.Date(d.Year(), d.Month(), d.Day(), 0, 0, 0, 0, loc)
}

func (weekStrategy) Next(t time.Time) time.Time {
	return t.AddDate(0, 0, 7)
}

type monthStrategy struct{}

func (monthStrategy) Truncate(t time.Time, loc *time.Location) time.Time {
	t = t.In(loc)
	return time.Date(t.Year(), t.Month(), 1, 0, 0, 0, 0, loc)
}

func (monthStrategy) Next(t time.Time) time.Time {
	return t.AddDate(0, 1, 0)
}

type yearStrategy struct{}

func (yearStrategy) Truncate(t time.Time, loc *time.Location) time.Time {
	t = t.In(loc)
	return time.Date(t.Year(), 1, 1, 0, 0, 0, 0, loc)
}

func (yearStrategy) Next(t time.Time) time.Time {
	return t.AddDate(1, 0, 0)
}

var scopeStrategies = map[Scope]ScopeStrategy{
	Week:  weekStrategy{},
	Month: monthStrategy{},
	Year:  yearStrategy{},
}

type Service struct {
	transactionProvider TransactionProvider
}

func NewService(transactionProvider TransactionProvider) *Service {
	return &Service{
		transactionProvider: transactionProvider,
	}
}

func (s *Service) GetPaymentStatistics(ctx context.Context, scopeStr string, startDate, endDate time.Time, ownerID uuid.UUID) ([]response.PaymentMetricResponse, error) {
	if endDate.Before(startDate) {
		logger.WarnContext(ctx, "Invalid date range for payment statistics",
			"start_date", startDate.Format(time.RFC3339),
			"end_date", endDate.Format(time.RFC3339),
			"user_id", ownerID.String(),
		)
		return nil, pkgerrors.NewBadRequest("endDate must not be before startDate")
	}

	scope := strings.ToUpper(strings.TrimSpace(scopeStr))
	if scope == "" {
		scope = string(Month)
	}

	strategy, ok := scopeStrategies[Scope(scope)]
	if !ok {
		strategy = scopeStrategies[Month]
	}

	logger.InfoContext(ctx, "Getting payment statistics",
		"scope", scope,
		"start_date", startDate.Format(time.RFC3339),
		"end_date", endDate.Format(time.RFC3339),
		"user_id", ownerID.String(),
	)

	var txList []response.TransactionResponse
	if s.transactionProvider != nil {
		var err error
		txList, err = s.transactionProvider.GetTransactionsBetween(ctx, startDate, endDate, ownerID)
		if err != nil {
			logger.ErrorContext(ctx, "Failed to fetch transactions for payment statistics",
				"error", err,
				"start_date", startDate.Format(time.RFC3339),
				"end_date", endDate.Format(time.RFC3339),
				"user_id", ownerID.String(),
			)
			return nil, err
		}
	}

	loc := startDate.Location()
	totalsByBucket := make(map[int64]float64)
	for _, tx := range txList {
		bucket := strategy.Truncate(tx.Date, loc)
		if tx.Type == transaction.TransactionTypeIncome {
			totalsByBucket[bucket.Unix()] += tx.Amount
		} else {
			totalsByBucket[bucket.Unix()] -= tx.Amount
		}
	}

	metrics := make([]response.PaymentMetricResponse, 0)
	current := strategy.Truncate(startDate, loc)
	limit := strategy.Truncate(endDate, loc)
	for !current.After(limit) {
		amount := totalsByBucket[current.Unix()]
		metrics = append(metrics, response.PaymentMetricResponse{
			Date:  current,
			Total: amount,
		})
		current = strategy.Next(current)
	}

	logger.InfoContext(ctx, "Payment statistics computed successfully",
		"scope", scope,
		"transactions_count", len(txList),
		"buckets_count", len(metrics),
		"user_id", ownerID.String(),
	)
	return metrics, nil
}
