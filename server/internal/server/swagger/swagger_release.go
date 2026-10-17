//go:build release

package swagger

import "github.com/gin-gonic/gin"

func SetupSwagger(r *gin.Engine) {
	// Swagger is disabled in production
}
