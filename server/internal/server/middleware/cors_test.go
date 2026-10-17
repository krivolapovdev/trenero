package middleware

import (
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gin-gonic/gin"
	"github.com/stretchr/testify/assert"
)

func TestCorsMiddleware(t *testing.T) {
	gin.SetMode(gin.TestMode)
	r := gin.New()
	r.Use(CorsMiddleware([]string{"https://app.trenero.org"}))
	r.GET("/ping", func(c *gin.Context) {
		c.String(http.StatusOK, "pong")
	})

	t.Run("OptionsPreflight", func(t *testing.T) {
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodOptions, "/ping", nil)
		req.Header.Set("Origin", "https://app.trenero.org")
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusNoContent, w.Code)
		assert.Equal(t, "https://app.trenero.org", w.Header().Get("Access-Control-Allow-Origin"))
		assert.Contains(t, w.Header().Get("Access-Control-Allow-Methods"), "GET")
	})

	t.Run("AllowedOrigin", func(t *testing.T) {
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodGet, "/ping", nil)
		req.Header.Set("Origin", "https://app.trenero.org")
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusOK, w.Code)
		assert.Equal(t, "https://app.trenero.org", w.Header().Get("Access-Control-Allow-Origin"))
	})

	t.Run("DisallowedOrigin", func(t *testing.T) {
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodGet, "/ping", nil)
		req.Header.Set("Origin", "https://malicious.org")
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusOK, w.Code)
		assert.Empty(t, w.Header().Get("Access-Control-Allow-Origin"))
	})
}

func TestCorsMiddleware_WildcardAndDisallowedPreflight(t *testing.T) {
	gin.SetMode(gin.TestMode)

	t.Run("WildcardOriginReflectsAndAllowsCredentials", func(t *testing.T) {
		r := gin.New()
		r.Use(CorsMiddleware([]string{"*"}))
		r.GET("/api/test", func(c *gin.Context) {
			c.String(http.StatusOK, "ok")
		})

		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodGet, "/api/test", nil)
		req.Header.Set("Origin", "https://my-frontend.domain.com")
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusOK, w.Code)
		assert.Equal(t, "https://my-frontend.domain.com", w.Header().Get("Access-Control-Allow-Origin"))
		assert.Equal(t, "true", w.Header().Get("Access-Control-Allow-Credentials"))
		assert.NotContains(t, w.Header().Get("Access-Control-Expose-Headers"), "*")
	})

	t.Run("DisallowedOriginPreflightOptionsReturnsForbidden", func(t *testing.T) {
		r := gin.New()
		r.Use(CorsMiddleware([]string{"https://trusted.org"}))
		r.GET("/api/test", func(c *gin.Context) {
			c.String(http.StatusOK, "ok")
		})

		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodOptions, "/api/test", nil)
		req.Header.Set("Origin", "https://untrusted-hacker.com")
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusForbidden, w.Code)
		assert.Empty(t, w.Header().Get("Access-Control-Allow-Origin"))
	})
}
