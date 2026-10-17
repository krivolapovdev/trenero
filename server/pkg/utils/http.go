package utils

import (
	"fmt"
	"strconv"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	pkgerrors "github.com/krivolapovdev/trenerio/pkg/errors"
	"github.com/krivolapovdev/trenerio/pkg/security"
	"github.com/krivolapovdev/trenerio/pkg/types"
)

// GetAuthUser extracts the authenticated JwtUser from the Gin context.
// If the user does not exist or has an invalid type, it responds with 401 Unauthorized, aborts the context, and returns false.
func GetAuthUser(c *gin.Context) (security.JwtUser, bool) {
	val, exists := c.Get(types.ContextKeyJWTUser)
	if !exists {
		pkgerrors.RespondUnauthorized(c, "")
		c.Abort()
		return security.JwtUser{}, false
	}
	u, ok := val.(security.JwtUser)
	if !ok {
		pkgerrors.RespondUnauthorized(c, "")
		c.Abort()
		return security.JwtUser{}, false
	}
	return u, true
}

// ParseUUIDParam parses a route parameter as a UUID.
// If invalid, it responds with 400 Bad Request and returns false.
func ParseUUIDParam(c *gin.Context, paramName string) (uuid.UUID, bool) {
	val := c.Param(paramName)
	id, err := uuid.Parse(val)
	if err != nil {
		pkgerrors.RespondBadRequest(c, fmt.Sprintf("Invalid %s", paramName))
		return uuid.Nil, false
	}
	return id, true
}

// BindJSON binds the request JSON body to obj.
// If binding fails, it responds with 400 Bad Request and returns false.
func BindJSON(c *gin.Context, obj any) bool {
	if err := c.ShouldBindJSON(obj); err != nil {
		pkgerrors.RespondBadRequest(c, "Request body is missing or has invalid format")
		return false
	}
	return true
}

// ParsePagination parses page and size query parameters with defaults.
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

	return page, size
}

// ParseOptionalRFC3339 parses an optional RFC3339 query parameter.
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
