package middleware

import (
	"github.com/gin-gonic/gin"
	pkgerrors "github.com/krivolapovdev/trenerio/internal/shared/errors"
)

func ErrorHandlerMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		c.Next()
		if len(c.Errors) > 0 && !c.Writer.Written() {
			lastErr := c.Errors.Last().Err
			pkgerrors.HandleError(c, lastErr)
		}
	}
}
