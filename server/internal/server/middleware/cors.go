package middleware

import (
	"net/http"
	"time"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
	"github.com/krivolapovdev/trenerio/internal/shared/web"
)

func CorsMiddleware(allowedOrigins []string) gin.HandlerFunc {
	allowAll := len(allowedOrigins) == 0 || (len(allowedOrigins) == 1 && allowedOrigins[0] == "*")
	originMap := make(map[string]bool, len(allowedOrigins))
	for _, origin := range allowedOrigins {
		originMap[origin] = true
	}

	config := cors.Config{
		AllowMethods:     []string{http.MethodGet, http.MethodPost, http.MethodPut, http.MethodPatch, http.MethodDelete, http.MethodOptions},
		AllowHeaders:     []string{web.HeaderAuthorization, "Content-Type", web.HeaderXReviewerKey, web.HeaderXRequestID, "Origin", "Accept"},
		ExposeHeaders:    []string{web.HeaderXRequestID},
		AllowCredentials: true,
		MaxAge:           12 * time.Hour,
	}

	if allowAll {
		config.AllowOriginFunc = func(origin string) bool { return true }
	} else {
		config.AllowOrigins = allowedOrigins
	}

	corsHandler := cors.New(config)
	return func(c *gin.Context) {
		origin := c.GetHeader("Origin")
		if origin != "" && !allowAll && !originMap[origin] {
			if c.Request.Method == http.MethodOptions {
				c.AbortWithStatus(http.StatusForbidden)
				return
			}
			c.Next()
			return
		}

		corsHandler(c)
		if c.Request.Method == http.MethodOptions && !c.IsAborted() {
			c.AbortWithStatus(http.StatusNoContent)
		}
	}
}
