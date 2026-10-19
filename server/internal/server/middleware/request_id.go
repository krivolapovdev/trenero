package middleware

import (
	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/krivolapovdev/trenerio/internal/shared/logger"
	"github.com/krivolapovdev/trenerio/internal/shared/web"
)

func RequestIDMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		reqID := c.GetHeader(web.HeaderXRequestID)
		if reqID == "" {
			reqID = c.GetHeader(web.HeaderRequestID)
		}
		if reqID == "" {
			reqID = uuid.New().String()
		}

		c.Header(web.HeaderXRequestID, reqID)
		c.Set(web.ContextKeyRequestID, reqID)
		c.Request = c.Request.WithContext(logger.WithRequestID(c.Request.Context(), reqID))

		c.Next()
	}
}
