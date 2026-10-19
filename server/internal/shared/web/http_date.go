package web

import (
	"fmt"
	"time"

	"github.com/gin-gonic/gin"
	pkgerrors "github.com/krivolapovdev/trenerio/internal/shared/errors"
)

// ParseRequiredRFC3339 parses a required RFC3339 query parameter from the Gin context.
// If the parameter is missing or has an invalid format, it responds with 400 Bad Request, aborts, and returns false.
func ParseRequiredRFC3339(c *gin.Context, paramName string) (time.Time, bool) {
	val := c.Query(paramName)
	if val == "" {
		pkgerrors.RespondBadRequest(c, fmt.Sprintf("%s query parameter is required", paramName))
		c.Abort()
		return time.Time{}, false
	}

	t, err := time.Parse(time.RFC3339, val)
	if err != nil {
		pkgerrors.RespondBadRequest(c, fmt.Sprintf("Invalid %s format", paramName))
		c.Abort()
		return time.Time{}, false
	}

	return t, true
}

// ParseRequiredRFC3339Range parses a pair of required RFC3339 query parameters from the Gin context.
// If either parameter is missing, it responds with the specified requiredMsg, aborts, and returns false.
// If either parameter has an invalid format, it responds with 400 Bad Request, aborts, and returns false.
func ParseRequiredRFC3339Range(c *gin.Context, startParam, endParam, requiredMsg string) (time.Time, time.Time, bool) {
	startStr := c.Query(startParam)
	endStr := c.Query(endParam)

	if startStr == "" || endStr == "" {
		if requiredMsg == "" {
			requiredMsg = fmt.Sprintf("%s and %s are required", startParam, endParam)
		}

		pkgerrors.RespondBadRequest(c, requiredMsg)
		c.Abort()
		return time.Time{}, time.Time{}, false
	}

	startDate, err := time.Parse(time.RFC3339, startStr)
	if err != nil {
		pkgerrors.RespondBadRequest(c, fmt.Sprintf("Invalid %s format", startParam))
		c.Abort()
		return time.Time{}, time.Time{}, false
	}

	endDate, err := time.Parse(time.RFC3339, endStr)
	if err != nil {
		pkgerrors.RespondBadRequest(c, fmt.Sprintf("Invalid %s format", endParam))
		c.Abort()
		return time.Time{}, time.Time{}, false
	}

	return startDate, endDate, true
}
