package metric

import (
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	pkgerrors "github.com/krivolapovdev/trenerio/pkg/errors"
	"github.com/krivolapovdev/trenerio/pkg/models"
	"github.com/krivolapovdev/trenerio/pkg/security"
	"github.com/krivolapovdev/trenerio/pkg/testutil"
	"github.com/krivolapovdev/trenerio/pkg/types"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

type mockMetricService struct {
	getPaymentStatisticsFn func(ctx context.Context, scopeStr string, startDate, endDate time.Time, ownerID uuid.UUID) ([]models.PaymentMetricResponse, error)
}

func (m *mockMetricService) GetPaymentStatistics(ctx context.Context, scopeStr string, startDate, endDate time.Time, ownerID uuid.UUID) ([]models.PaymentMetricResponse, error) {
	if m.getPaymentStatisticsFn != nil {
		return m.getPaymentStatisticsFn(ctx, scopeStr, startDate, endDate, ownerID)
	}
	return nil, nil
}

func setupMetricRouter(svc metricService, user security.JwtUser) *gin.Engine {
	return testutil.SetupTestRouter(user, func(rg *gin.RouterGroup) {
		NewHandler(svc).RegisterRoutes(rg)
	})
}

func TestMetricHandler_GetPaymentStatistics(t *testing.T) {
	testUser := security.JwtUser{ID: uuid.New(), Email: "coach@example.com"}
	startDate := time.Date(2026, 1, 1, 0, 0, 0, 0, time.UTC)
	endDate := time.Date(2026, 12, 31, 23, 59, 59, 0, time.UTC)

	t.Run("Unauthorized", func(t *testing.T) {
		r := setupMetricRouter(&mockMetricService{}, security.JwtUser{})
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodGet, "/api/v1/metrics/payments", nil)
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusUnauthorized, w.Code)
	})

	t.Run("MissingRequiredDates", func(t *testing.T) {
		r := setupMetricRouter(&mockMetricService{}, testUser)
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodGet, "/api/v1/metrics/payments?startDate="+startDate.Format(time.RFC3339), nil)
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusBadRequest, w.Code)
	})

	t.Run("InvalidDateFormat", func(t *testing.T) {
		r := setupMetricRouter(&mockMetricService{}, testUser)
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodGet, "/api/v1/metrics/payments?startDate=not-a-date&endDate=not-a-date", nil)
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusBadRequest, w.Code)
	})

	t.Run("SuccessWithDefaultScope", func(t *testing.T) {
		expected := []models.PaymentMetricResponse{
			{Date: startDate, Total: 15000.0},
		}

		mockSvc := &mockMetricService{
			getPaymentStatisticsFn: func(ctx context.Context, scopeStr string, start, end time.Time, ownerID uuid.UUID) ([]models.PaymentMetricResponse, error) {
				assert.Equal(t, string(types.MetricScopeMonth), scopeStr)
				assert.True(t, startDate.Equal(start))
				assert.True(t, endDate.Equal(end))
				assert.Equal(t, testUser.ID, ownerID)
				return expected, nil
			},
		}

		r := setupMetricRouter(mockSvc, testUser)
		w := httptest.NewRecorder()
		url := "/api/v1/metrics/payments?startDate=" + startDate.Format(time.RFC3339) + "&endDate=" + endDate.Format(time.RFC3339)
		req := httptest.NewRequest(http.MethodGet, url, nil)
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusOK, w.Code)
		var actual []models.PaymentMetricResponse
		err := json.Unmarshal(w.Body.Bytes(), &actual)
		require.NoError(t, err)
		assert.Len(t, actual, 1)
		assert.Equal(t, 15000.0, actual[0].Total)
	})

	t.Run("SuccessWithExplicitScope", func(t *testing.T) {
		mockSvc := &mockMetricService{
			getPaymentStatisticsFn: func(ctx context.Context, scopeStr string, start, end time.Time, ownerID uuid.UUID) ([]models.PaymentMetricResponse, error) {
				assert.Equal(t, "WEEK", scopeStr)
				return []models.PaymentMetricResponse{}, nil
			},
		}

		r := setupMetricRouter(mockSvc, testUser)
		w := httptest.NewRecorder()
		url := "/api/v1/metrics/payments?scope=WEEK&startDate=" + startDate.Format(time.RFC3339) + "&endDate=" + endDate.Format(time.RFC3339)
		req := httptest.NewRequest(http.MethodGet, url, nil)
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusOK, w.Code)
	})

	t.Run("DateRangeServiceError", func(t *testing.T) {
		mockSvc := &mockMetricService{
			getPaymentStatisticsFn: func(ctx context.Context, scopeStr string, start, end time.Time, ownerID uuid.UUID) ([]models.PaymentMetricResponse, error) {
				return nil, pkgerrors.NewBadRequest("endDate must not be before startDate")
			},
		}

		r := setupMetricRouter(mockSvc, testUser)
		w := httptest.NewRecorder()
		url := "/api/v1/metrics/payments?startDate=" + endDate.Format(time.RFC3339) + "&endDate=" + startDate.Format(time.RFC3339)
		req := httptest.NewRequest(http.MethodGet, url, nil)
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusBadRequest, w.Code)
	})

	t.Run("MissingEndDate", func(t *testing.T) {
		r := setupMetricRouter(&mockMetricService{}, testUser)
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodGet, "/api/v1/metrics/payments?startDate="+startDate.Format(time.RFC3339), nil)
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusBadRequest, w.Code)
	})

	t.Run("InternalServerError", func(t *testing.T) {
		mockSvc := &mockMetricService{
			getPaymentStatisticsFn: func(ctx context.Context, scopeStr string, start, end time.Time, ownerID uuid.UUID) ([]models.PaymentMetricResponse, error) {
				return nil, assert.AnError
			},
		}

		r := setupMetricRouter(mockSvc, testUser)
		w := httptest.NewRecorder()
		url := "/api/v1/metrics/payments?startDate=" + startDate.Format(time.RFC3339) + "&endDate=" + endDate.Format(time.RFC3339)
		req := httptest.NewRequest(http.MethodGet, url, nil)
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusInternalServerError, w.Code)
	})
}
