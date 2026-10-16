package server

import (
	"fmt"
	"net/http"
	"runtime/debug"
	"strings"
	"time"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	pkgerrors "github.com/krivolapovdev/trenerio/pkg/errors"
	"github.com/krivolapovdev/trenerio/pkg/logger"
	"github.com/krivolapovdev/trenerio/pkg/security"
	"github.com/krivolapovdev/trenerio/pkg/types"
)

func RequestIDMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		reqID := c.GetHeader(types.HeaderXRequestID)
		if reqID == "" {
			reqID = c.GetHeader(types.HeaderRequestID)
		}
		if reqID == "" {
			reqID = uuid.New().String()
		}

		c.Header(types.HeaderXRequestID, reqID)
		c.Set(types.ContextKeyRequestID, reqID)
		c.Request = c.Request.WithContext(logger.WithRequestID(c.Request.Context(), reqID))

		c.Next()
	}
}

func LoggingMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		start := time.Now()
		c.Next()
		latency := time.Since(start)

		status := c.Writer.Status()
		ctx := c.Request.Context()

		attrs := []any{
			"status", status,
			"method", c.Request.Method,
			"path", c.Request.URL.Path,
			"latency_ms", float64(latency.Microseconds()) / 1000.0,
			"ip", c.ClientIP(),
			"bytes", c.Writer.Size(),
		}

		if query := c.Request.URL.RawQuery; query != "" {
			attrs = append(attrs, "query", query)
		}

		if userVal, exists := c.Get(types.ContextKeyJWTUser); exists {
			if u, ok := userVal.(security.JwtUser); ok {
				attrs = append(attrs, "user_id", u.ID.String(), "user_email", u.Email)
			}
		}

		if len(c.Errors) > 0 {
			attrs = append(attrs, "gin_errors", c.Errors.String())
		}

		if status >= http.StatusInternalServerError {
			logger.ErrorContext(ctx, "HTTP request failed", attrs...)
		} else if status >= http.StatusBadRequest {
			logger.WarnContext(ctx, "HTTP request client error", attrs...)
		} else {
			logger.InfoContext(ctx, "HTTP request completed", attrs...)
		}
	}
}

func CorsMiddleware(allowedOrigins []string) gin.HandlerFunc {
	allowAll := len(allowedOrigins) == 0 || (len(allowedOrigins) == 1 && allowedOrigins[0] == "*")
	originMap := make(map[string]bool, len(allowedOrigins))
	for _, origin := range allowedOrigins {
		originMap[origin] = true
	}

	config := cors.Config{
		AllowMethods:     []string{http.MethodGet, http.MethodPost, http.MethodPut, http.MethodPatch, http.MethodDelete, http.MethodOptions},
		AllowHeaders:     []string{types.HeaderAuthorization, "Content-Type", types.HeaderXReviewerKey, types.HeaderXRequestID, "Origin", "Accept"},
		ExposeHeaders:    []string{types.HeaderXRequestID, "*"},
		AllowCredentials: true,
		MaxAge:           12 * time.Hour,
	}

	if allowAll {
		config.AllowAllOrigins = true
	} else {
		config.AllowOrigins = allowedOrigins
	}

	corsHandler := cors.New(config)
	return func(c *gin.Context) {
		origin := c.GetHeader("Origin")
		if origin != "" && !allowAll && !originMap[origin] {
			c.Next()
			return
		}

		corsHandler(c)
		if c.Request.Method == http.MethodOptions && !c.IsAborted() {
			c.AbortWithStatus(http.StatusNoContent)
		}
	}
}

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

func RecoveryMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		defer func() {
			if r := recover(); r != nil {
				ctx := c.Request.Context()
				logger.ErrorContext(ctx, "Panic recovered",
					"error", fmt.Sprintf("%v", r),
					"stack", string(debug.Stack()),
					"path", c.Request.URL.Path,
					"method", c.Request.Method,
				)
				pkgerrors.RespondProblem(c, http.StatusInternalServerError, "Internal Server Error", fmt.Sprintf("%v", r))
				c.Abort()
			}
		}()
		c.Next()
	}
}

func ErrorHandlerMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		c.Next()
		if len(c.Errors) > 0 && !c.Writer.Written() {
			lastErr := c.Errors.Last().Err
			pkgerrors.HandleError(c, lastErr)
		}
	}
}
