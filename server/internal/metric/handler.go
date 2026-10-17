package metric

import (
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	pkgerrors "github.com/krivolapovdev/trenerio/pkg/errors"
	"github.com/krivolapovdev/trenerio/pkg/types"
	httputil "github.com/krivolapovdev/trenerio/pkg/utils"
)

type Handler struct {
	service Service
}

func NewHandler(service Service) *Handler {
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
// @Success      200        {array}   models.PaymentMetricResponse
// @Router       /api/v1/metrics/payments [get]
func (h *Handler) GetPaymentStatistics(c *gin.Context) {
	jwtUser, ok := httputil.GetAuthUser(c)
	if !ok {
		return
	}

	scope := c.DefaultQuery("scope", string(types.MetricScopeMonth))
	startDateStr := c.Query("startDate")
	endDateStr := c.Query("endDate")

	if startDateStr == "" || endDateStr == "" {
		pkgerrors.RespondBadRequest(c, "startDate and endDate are required")
		return
	}

	startDate, err := time.Parse(time.RFC3339, startDateStr)
	if err != nil {
		pkgerrors.RespondBadRequest(c, "Invalid startDate format")
		return
	}

	endDate, err := time.Parse(time.RFC3339, endDateStr)
	if err != nil {
		pkgerrors.RespondBadRequest(c, "Invalid endDate format")
		return
	}

	stats, err := h.service.GetPaymentStatistics(c.Request.Context(), scope, startDate, endDate, jwtUser.ID)
	if err != nil {
		pkgerrors.HandleError(c, err)
		return
	}

	c.JSON(http.StatusOK, stats)
}
