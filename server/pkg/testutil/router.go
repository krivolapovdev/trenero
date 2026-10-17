package testutil

import (
	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/krivolapovdev/trenerio/pkg/security"
	"github.com/krivolapovdev/trenerio/pkg/types"
)

// SetupTestRouter creates a test Gin engine in test mode with an authentication middleware
// that injects user into the context if user.ID != uuid.Nil, and invokes registerRoutes on "/api/v1".
func SetupTestRouter(user security.JwtUser, registerRoutes func(rg *gin.RouterGroup)) *gin.Engine {
	gin.SetMode(gin.TestMode)
	r := gin.New()
	r.Use(func(c *gin.Context) {
		if user.ID != uuid.Nil {
			c.Set(types.ContextKeyJWTUser, user)
		}
		c.Next()
	})
	registerRoutes(r.Group("/api/v1"))
	return r
}
