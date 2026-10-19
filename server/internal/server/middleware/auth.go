package middleware

import (
	"strings"

	"github.com/gin-gonic/gin"
	"github.com/krivolapovdev/trenerio/internal/auth"
	pkgerrors "github.com/krivolapovdev/trenerio/internal/shared/errors"
	"github.com/krivolapovdev/trenerio/internal/shared/logger"
	"github.com/krivolapovdev/trenerio/internal/shared/web"
)

const BearerPrefix = "Bearer "

func AuthMiddleware(tokenProvider *auth.TokenProvider) gin.HandlerFunc {
	return func(c *gin.Context) {
		authHeader := c.GetHeader(web.HeaderAuthorization)
		if authHeader == "" || !strings.HasPrefix(authHeader, BearerPrefix) {
			logger.WarnContext(c.Request.Context(), "Missing or invalid Bearer token",
				"path", c.Request.URL.Path,
				"ip", c.ClientIP(),
			)
			pkgerrors.RespondUnauthorized(c, "Full authentication is required to access this resource")
			c.Abort()
			return
		}

		token := strings.TrimSpace(strings.TrimPrefix(authHeader, BearerPrefix))
		if token == "" || !tokenProvider.IsTokenValid(token, auth.TokenTypeAccess) {
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

		c.Set(auth.ContextKeyJWTUser, user)
		c.Request = c.Request.WithContext(logger.WithUserID(c.Request.Context(), user.ID.String()))
		c.Next()
	}
}
