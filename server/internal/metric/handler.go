package metric

import (
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	pkgerrors "github.com/krivolapovdev/trenerio/pkg/errors"
	"github.com/krivolapovdev/trenerio/pkg/security"
)

type MetricHandler struct {
	service *MetricService
}

func NewMetricHandler(service *MetricService) *MetricHandler {
	return &MetricHandler{
		service: service,
	}
}

func (h *MetricHandler) GetPaymentStatistics(c *gin.Context) {
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

	startDate, err := time.Parse(time.RFC3339Nano, startDateStr)
	if err != nil {
		startDate, err = time.Parse(time.RFC3339, startDateStr)
		if err != nil {
			pkgerrors.RespondBadRequest(c, "Invalid startDate format")
			return
		}
	}

	endDate, err := time.Parse(time.RFC3339Nano, endDateStr)
	if err != nil {
		endDate, err = time.Parse(time.RFC3339, endDateStr)
		if err != nil {
			pkgerrors.RespondBadRequest(c, "Invalid endDate format")
			return
		}
	}

	stats, err := h.service.GetPaymentStatistics(c.Request.Context(), scope, startDate, endDate, jwtUser.ID)
	if err != nil {
		pkgerrors.HandleError(c, err)
		return
	}

	c.JSON(http.StatusOK, stats)
}
