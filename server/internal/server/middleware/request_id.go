package middleware

import (
	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/krivolapovdev/trenerio/pkg/logger"
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
