package web

import (
	"fmt"
	"strconv"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	pkgerrors "github.com/krivolapovdev/trenerio/internal/shared/errors"
)

const (
	ContextKeyJWTUser   = "jwtUser"
	ContextKeyRequestID = "requestID"
)

const (
	HeaderAuthorization = "Authorization"
	HeaderXRequestID    = "X-Request-ID"
	HeaderRequestID     = "Request-ID"
	HeaderXReviewerKey  = "X-Reviewer-Key"
)

func ParseUUIDParam(c *gin.Context, paramName string) (uuid.UUID, bool) {
	val := c.Param(paramName)
	id, err := uuid.Parse(val)
	if err != nil {
		pkgerrors.RespondBadRequest(c, fmt.Sprintf("Invalid %s", paramName))
		c.Abort()
		return uuid.Nil, false
	}
	return id, true
}

func BindJSON(c *gin.Context, obj any) bool {
	if err := c.ShouldBindJSON(obj); err != nil {
		pkgerrors.RespondBadRequest(c, "Request body is missing or has invalid format")
		c.Abort()
		return false
	}
	return true
}

func ParsePagination(c *gin.Context, defaultPage, defaultSize int) (int, int) {
	page := defaultPage
	if pageStr := c.Query("page"); pageStr != "" {
		if val, err := strconv.Atoi(pageStr); err == nil && val > 0 {
			page = val
		}
	}

	size := defaultSize
	if sizeStr := c.Query("size"); sizeStr != "" {
		if val, err := strconv.Atoi(sizeStr); err == nil && val > 0 {
			size = val
		}
	}

	const maxPageSize = 100
	if size > maxPageSize {
		size = maxPageSize
	}

	return page, size
}

func ParseOptionalRFC3339(c *gin.Context, paramName string) *time.Time {
	val := c.Query(paramName)
	if val == "" {
		return nil
	}
	t, err := time.Parse(time.RFC3339, val)
	if err != nil {
		return nil
	}
	return &t
}
