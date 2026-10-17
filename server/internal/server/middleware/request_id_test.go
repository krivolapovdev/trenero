package middleware

import (
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gin-gonic/gin"
	"github.com/stretchr/testify/assert"
)

func TestRequestIDMiddleware(t *testing.T) {
	gin.SetMode(gin.TestMode)
	r := gin.New()
	r.Use(RequestIDMiddleware())
	r.GET("/test", func(c *gin.Context) {
		reqID, exists := c.Get("requestID")
		assert.True(t, exists)
		assert.NotEmpty(t, reqID)
		c.String(http.StatusOK, "ok")
	})

	t.Run("GeneratesNewRequestID", func(t *testing.T) {
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodGet, "/test", nil)
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusOK, w.Code)
		respReqID := w.Header().Get("X-Request-ID")
		assert.NotEmpty(t, respReqID)
	})

	t.Run("PreservesIncomingRequestID", func(t *testing.T) {
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodGet, "/test", nil)
		req.Header.Set("X-Request-ID", "custom-trace-id-12345")
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusOK, w.Code)
		assert.Equal(t, "custom-trace-id-12345", w.Header().Get("X-Request-ID"))
	})
}
