package metric

import (
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	pkgerrors "github.com/krivolapovdev/trenerio/pkg/errors"
	"github.com/krivolapovdev/trenerio/pkg/security"
)

type Handler struct {
	service *Service
}

func NewHandler(service *Service) *Handler {
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
	jwtUser, ok := c.MustGet("jwtUser").(security.JwtUser)
	if !ok {
		pkgerrors.RespondUnauthorized(c, "")
		return
	}

	scope := c.DefaultQuery("scope", "MONTH")
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
