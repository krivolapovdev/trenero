package harness

import (
	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/krivolapovdev/trenerio/internal/auth"
)

func SetupTestRouter(user auth.JwtUser, registerRoutes func(rg *gin.RouterGroup)) *gin.Engine {
	gin.SetMode(gin.TestMode)
	r := gin.New()
	r.Use(func(c *gin.Context) {
		if user.ID != uuid.Nil {
			c.Set(auth.ContextKeyJWTUser, user)
		}
		c.Next()
	})
	registerRoutes(r.Group("/api/v1"))
	return r
}
