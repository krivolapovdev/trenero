package metric

import (
	"context"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	pkgerrors "github.com/krivolapovdev/trenerio/pkg/errors"
	"github.com/krivolapovdev/trenerio/pkg/models"
	"github.com/krivolapovdev/trenerio/pkg/security"
)

type MetricService interface {
	GetPaymentStatistics(ctx context.Context, scopeStr string, startDate, endDate time.Time, ownerID uuid.UUID) ([]models.PaymentMetricResponse, error)
}

type Handler struct {
	service MetricService
}

func NewHandler(service MetricService) *Handler {
	return &Handler{
		service: service,
	}
}

// GetPaymentStatistics
// @ID           getPaymentStatistics
// @Tags         metric-controller
// @Security     BearerAuth
// @Param        scope      query     string  false  "Aggregation scope"      Enums(WEEK, MONTH, YEAR)  default(MONTH)
// @Param        startDate  query     string  true   "Start date (RFC3339)"   Format(date-time)
// @Param        endDate    query     string  true   "End date (RFC3339)"     Format(date-time)
// @Success      200        {array}   models.PaymentMetricResponse
// @Router       /api/v1/metrics/payments [get]
func (h *Handler) GetPaymentStatistics(c *gin.Context) {
	val, exists := c.Get("jwtUser")
	if !exists {
		pkgerrors.RespondUnauthorized(c, "")
		c.Abort()
		return
	}
	jwtUser, ok := val.(security.JwtUser)
	if !ok {
		pkgerrors.RespondUnauthorized(c, "")
		c.Abort()
		return
	}

	scope := c.DefaultQuery("scope", "MONTH")
	startDateStr := c.Query("startDate")
	endDateStr := c.Query("endDate")

	if startDateStr == "" || endDateStr == "" {
		pkgerrors.RespondBadRequest(c, "startDate and endDate are required")
		c.Abort()
		return
	}

	startDate, err := time.Parse(time.RFC3339, startDateStr)
	if err != nil {
		pkgerrors.RespondBadRequest(c, "Invalid startDate format")
		c.Abort()
		return
	}

	endDate, err := time.Parse(time.RFC3339, endDateStr)
	if err != nil {
		pkgerrors.RespondBadRequest(c, "Invalid endDate format")
		c.Abort()
		return
	}

	stats, err := h.service.GetPaymentStatistics(c.Request.Context(), scope, startDate, endDate, jwtUser.ID)
	if err != nil {
		pkgerrors.HandleError(c, err)
		return
	}

	c.JSON(http.StatusOK, stats)
}
