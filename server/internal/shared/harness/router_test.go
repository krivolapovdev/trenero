package harness

import (
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/krivolapovdev/trenerio/internal/auth"
	"github.com/stretchr/testify/assert"
)

func TestSetupTestRouter(t *testing.T) {
	testUser := auth.JwtUser{
		ID:    uuid.New(),
		Email: "test@example.com",
	}

	t.Run("AuthenticatedUser", func(t *testing.T) {
		r := SetupTestRouter(testUser, func(rg *gin.RouterGroup) {
			rg.GET("/ping", func(c *gin.Context) {
				c.String(http.StatusOK, "pong")
			})
		})

		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodGet, "/api/v1/ping", nil)
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusOK, w.Code)
		assert.Equal(t, "pong", w.Body.String())
	})

	t.Run("AnonymousUser", func(t *testing.T) {
		r := SetupTestRouter(auth.JwtUser{}, func(rg *gin.RouterGroup) {
			rg.GET("/ping", func(c *gin.Context) {
				c.String(http.StatusOK, "anonymous")
			})
		})

		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodGet, "/api/v1/ping", nil)
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusOK, w.Code)
		assert.Equal(t, "anonymous", w.Body.String())
	})
}
