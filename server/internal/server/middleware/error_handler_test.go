package middleware

import (
	"errors"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gin-gonic/gin"
	"github.com/stretchr/testify/assert"
)

func TestErrorHandlerMiddleware(t *testing.T) {
	gin.SetMode(gin.TestMode)

	t.Run("HandlesGinError", func(t *testing.T) {
		r := gin.New()
		r.Use(ErrorHandlerMiddleware())
		r.GET("/err", func(c *gin.Context) {
			_ = c.Error(errors.New("some unexpected database error"))
		})

		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodGet, "/err", nil)
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusInternalServerError, w.Code)
		assert.Contains(t, w.Body.String(), "Internal Server Error")
	})

	t.Run("PassesThroughWhenNoError", func(t *testing.T) {
		r := gin.New()
		r.Use(ErrorHandlerMiddleware())
		r.GET("/ok", func(c *gin.Context) {
			c.String(http.StatusOK, "ok")
		})

		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodGet, "/ok", nil)
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusOK, w.Code)
		assert.Equal(t, "ok", w.Body.String())
	})

	t.Run("SkipsIfAlreadyWritten", func(t *testing.T) {
		r := gin.New()
		r.Use(ErrorHandlerMiddleware())
		r.GET("/written", func(c *gin.Context) {
			c.String(http.StatusAccepted, "custom response")
			_ = c.Error(errors.New("ignored error after write"))
		})

		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodGet, "/written", nil)
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusAccepted, w.Code)
		assert.Equal(t, "custom response", w.Body.String())
	})
}
