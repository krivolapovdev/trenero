package middleware

import (
	"fmt"
	"net/http"
	"runtime/debug"

	"github.com/gin-gonic/gin"
	pkgerrors "github.com/krivolapovdev/trenerio/internal/shared/errors"
	"github.com/krivolapovdev/trenerio/internal/shared/logger"
)

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
