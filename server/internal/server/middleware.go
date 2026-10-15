package server

import (
	"fmt"
	"net/http"
	"runtime/debug"
	"strings"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	pkgerrors "github.com/krivolapovdev/trenerio/pkg/errors"
	"github.com/krivolapovdev/trenerio/pkg/logger"
	"github.com/krivolapovdev/trenerio/pkg/security"
)

func RequestIDMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		reqID := c.GetHeader("X-Request-ID")
		if reqID == "" {
			reqID = c.GetHeader("Request-ID")
		}
		if reqID == "" {
			reqID = uuid.New().String()
		}

		c.Header("X-Request-ID", reqID)
		c.Set("requestID", reqID)
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

		if userVal, exists := c.Get("jwtUser"); exists {
			if u, ok := userVal.(security.JwtUser); ok {
				attrs = append(attrs, "user_id", u.ID.String(), "user_email", u.Email)
			}
		}

		if len(c.Errors) > 0 {
			attrs = append(attrs, "gin_errors", c.Errors.String())
		}

		if status >= 500 {
			logger.ErrorContext(ctx, "HTTP request failed", attrs...)
		} else if status >= 400 {
			logger.WarnContext(ctx, "HTTP request client error", attrs...)
		} else {
			logger.InfoContext(ctx, "HTTP request completed", attrs...)
		}
	}
}

func CorsMiddleware(allowedOrigins []string) gin.HandlerFunc {
	allowAll := len(allowedOrigins) == 0 || (len(allowedOrigins) == 1 && allowedOrigins[0] == "*")
	originMap := make(map[string]bool)
	for _, o := range allowedOrigins {
		originMap[o] = true
	}

	return func(c *gin.Context) {
		origin := c.GetHeader("Origin")
		if origin != "" {
			if allowAll {
				c.Header("Access-Control-Allow-Origin", "*")
			} else if originMap[origin] {
				c.Header("Access-Control-Allow-Origin", origin)
				c.Header("Vary", "Origin")
			}
		} else if allowAll {
			c.Header("Access-Control-Allow-Origin", "*")
		}

		c.Header("Access-Control-Allow-Methods", "GET, POST, PUT, PATCH, DELETE, OPTIONS")
		c.Header("Access-Control-Allow-Headers", "Authorization, Content-Type, X-Reviewer-Key, X-Request-ID, Origin, Accept")
		c.Header("Access-Control-Expose-Headers", "X-Request-ID, *")
		c.Header("Access-Control-Allow-Credentials", "true")

		if c.Request.Method == http.MethodOptions {
			c.AbortWithStatus(http.StatusNoContent)
			return
		}

		c.Next()
	}
}

func AuthMiddleware(tokenProvider *security.TokenProvider) gin.HandlerFunc {
	return func(c *gin.Context) {
		authHeader := c.GetHeader("Authorization")
		if authHeader == "" || !strings.HasPrefix(authHeader, "Bearer ") {
			logger.WarnContext(c.Request.Context(), "Missing or invalid Bearer token",
				"path", c.Request.URL.Path,
				"ip", c.ClientIP(),
			)
			pkgerrors.RespondUnauthorized(c, "Full authentication is required to access this resource")
			c.Abort()
			return
		}

		token := strings.TrimSpace(strings.TrimPrefix(authHeader, "Bearer "))
		if token == "" || !tokenProvider.IsTokenValid(token, "ACCESS") {
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

		c.Set("jwtUser", user)
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
