package middleware

import (
	"strings"

	"github.com/gin-gonic/gin"
	pkgerrors "github.com/krivolapovdev/trenerio/pkg/errors"
	"github.com/krivolapovdev/trenerio/pkg/logger"
	"github.com/krivolapovdev/trenerio/pkg/security"
	"github.com/krivolapovdev/trenerio/pkg/types"
)

func AuthMiddleware(tokenProvider *security.TokenProvider) gin.HandlerFunc {
	return func(c *gin.Context) {
		authHeader := c.GetHeader(types.HeaderAuthorization)
		if authHeader == "" || !strings.HasPrefix(authHeader, types.BearerPrefix) {
			logger.WarnContext(c.Request.Context(), "Missing or invalid Bearer token",
				"path", c.Request.URL.Path,
				"ip", c.ClientIP(),
			)
			pkgerrors.RespondUnauthorized(c, "Full authentication is required to access this resource")
			c.Abort()
			return
		}

		token := strings.TrimSpace(strings.TrimPrefix(authHeader, types.BearerPrefix))
		if token == "" || !tokenProvider.IsTokenValid(token, types.TokenTypeAccess) {
			logger.WarnContext(c.Request.Context(), "Token is invalid or expired",
				"path", c.Request.URL.Path,
				"ip", c.ClientIP(),
			)
			pkgerrors.RespondUnauthorized(c, "Full authentication is required to access this resource")
			c.Abort()
			return
		}

		user, err := tokenProvider.ExtractUser(token)
		if err != nil {
			logger.WarnContext(c.Request.Context(), "Failed to extract user from token",
				"path", c.Request.URL.Path,
				"error", err.Error(),
			)
			pkgerrors.RespondUnauthorized(c, "Full authentication is required to access this resource")
			c.Abort()
			return
		}

		c.Set(types.ContextKeyJWTUser, user)
		c.Request = c.Request.WithContext(logger.WithUserID(c.Request.Context(), user.ID.String()))
		c.Next()
	}
}
