package middleware

import (
	"log/slog"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/krivolapovdev/trenerio/internal/auth"
	"github.com/krivolapovdev/trenerio/internal/shared/logger"
	"github.com/krivolapovdev/trenerio/internal/shared/web"
)

func SlogMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		reqID := c.GetString(web.ContextKeyRequestID)
		if reqID == "" {
			reqID = c.GetHeader(web.HeaderXRequestID)
		}
		if reqID == "" {
			reqID = uuid.New().String()
		}

		ctx := logger.WithRequestID(c.Request.Context(), reqID)
		reqLogger := slog.Default().With(
			slog.String("request_id", reqID),
			slog.String("method", c.Request.Method),
			slog.String("path", c.Request.URL.Path),
		)
		ctx = logger.WithLogger(ctx, reqLogger)
		c.Request = c.Request.WithContext(ctx)

		start := time.Now()
		c.Next()
		latency := time.Since(start)

		status := c.Writer.Status()
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

		if userVal, exists := c.Get(auth.ContextKeyJWTUser); exists {
			if u, ok := userVal.(auth.JwtUser); ok {
				attrs = append(attrs, "user_id", u.ID.String(), "user_email", u.Email)
			}
		}

		if len(c.Errors) > 0 {
			attrs = append(attrs, "gin_errors", c.Errors.String())
		}

		reqCtx := c.Request.Context()
		switch {
		case status >= http.StatusInternalServerError:
			logger.ErrorContext(reqCtx, "HTTP request failed", attrs...)
		case status >= http.StatusBadRequest:
			logger.WarnContext(reqCtx, "HTTP request client error", attrs...)
		default:
			logger.InfoContext(reqCtx, "HTTP request completed", attrs...)
		}
	}
}

func LoggingMiddleware() gin.HandlerFunc {
	return SlogMiddleware()
}
