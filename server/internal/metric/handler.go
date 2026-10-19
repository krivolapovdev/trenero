package metric

import (
	"context"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/krivolapovdev/trenerio/internal/auth"
	pkgerrors "github.com/krivolapovdev/trenerio/internal/shared/errors"
	"github.com/krivolapovdev/trenerio/internal/shared/response"
	"github.com/krivolapovdev/trenerio/internal/shared/web"
)

type metricService interface {
	GetPaymentStatistics(ctx context.Context, scopeStr string, startDate, endDate time.Time, ownerID uuid.UUID) ([]response.PaymentMetricResponse, error)
}

type Handler struct {
	service metricService
}

func NewHandler(service metricService) *Handler {
	return &Handler{
		service: service,
	}
}

// RegisterRoutes registers the metric routes onto the given router group.
func (h *Handler) RegisterRoutes(rg *gin.RouterGroup) {
	metrics := rg.Group("/metrics")
	{
		metrics.GET("/payments", h.GetPaymentStatistics)
	}
}

// GetPaymentStatistics
// @ID           getPaymentStatistics
// @Tags         metric-controller
// @Security     BearerAuth
// @Param        scope      query     string  false  "Aggregation scope"      Enums(WEEK, MONTH, YEAR)  default(MONTH)
// @Param        startDate  query     string  true   "Start date (RFC3339)"   Format(date-time)
// @Param        endDate    query     string  true   "End date (RFC3339)"     Format(date-time)
// @Success      200        {array}   response.PaymentMetricResponse
// @Router       /api/v1/metrics/payments [get]
func (h *Handler) GetPaymentStatistics(c *gin.Context) {
	jwtUser, ok := auth.GetUserFromContext(c)
	if !ok {
		return
	}

	scope := c.DefaultQuery("scope", string(Month))
	startDate, endDate, ok := web.ParseRequiredRFC3339Range(c, "startDate", "endDate", "startDate and endDate are required")
	if !ok {
		return
	}

	stats, err := h.service.GetPaymentStatistics(c.Request.Context(), scope, startDate, endDate, jwtUser.ID)
	if err != nil {
		pkgerrors.HandleError(c, err)
		return
	}

	c.JSON(http.StatusOK, stats)
}
