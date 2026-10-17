package server

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"github.com/gin-gonic/gin"
	pkgerrors "github.com/krivolapovdev/trenerio/pkg/errors"
	"github.com/krivolapovdev/trenerio/pkg/security"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func init() {
	gin.SetMode(gin.TestMode)
}

func TestSwaggerEndpoint(t *testing.T) {
	tokenProvider := security.NewTokenProvider("super-secret-key-32-bytes-long!", time.Hour, 24*time.Hour, "reviewer-key")
	srv := NewServer(tokenProvider, []string{"*"}, nil, nil, nil, nil, nil, nil, nil)

	w := httptest.NewRecorder()
	req := httptest.NewRequest(http.MethodGet, "/swagger/doc.json", nil)
	srv.Engine().ServeHTTP(w, req)

	assert.Equal(t, http.StatusOK, w.Code)
	assert.Contains(t, w.Body.String(), `"title": "Trenerio API"`)
	assert.Contains(t, w.Body.String(), `"/api/v1/groups"`)
}

func TestHealthEndpoint(t *testing.T) {
	tokenProvider := security.NewTokenProvider("super-secret-key-32-bytes-long!", time.Hour, 24*time.Hour, "reviewer-key")
	srv := NewServer(tokenProvider, []string{"*"}, nil, nil, nil, nil, nil, nil, nil)

	w := httptest.NewRecorder()
	req := httptest.NewRequest(http.MethodGet, "/health", nil)
	srv.Engine().ServeHTTP(w, req)

	assert.Equal(t, http.StatusOK, w.Code)
	assert.Equal(t, "OK", w.Body.String())
}

func TestNoRouteAndNoMethod(t *testing.T) {
	tokenProvider := security.NewTokenProvider("super-secret-key-32-bytes-long!", time.Hour, 24*time.Hour, "reviewer-key")
	srv := NewServer(tokenProvider, []string{"*"}, nil, nil, nil, nil, nil, nil, nil)

	t.Run("NotFoundRoute", func(t *testing.T) {
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodGet, "/non-existent-route", nil)
		srv.Engine().ServeHTTP(w, req)

		assert.Equal(t, http.StatusNotFound, w.Code)
		var pd pkgerrors.ProblemDetail
		err := json.Unmarshal(w.Body.Bytes(), &pd)
		require.NoError(t, err)
		assert.Equal(t, "Not Found", pd.Title)
		assert.Equal(t, "Endpoint not found", pd.Detail)
	})

	t.Run("MethodNotAllowed", func(t *testing.T) {
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodPost, "/health", nil)
		srv.Engine().ServeHTTP(w, req)

		assert.Equal(t, http.StatusMethodNotAllowed, w.Code)
		var pd pkgerrors.ProblemDetail
		err := json.Unmarshal(w.Body.Bytes(), &pd)
		require.NoError(t, err)
		assert.Equal(t, "Method Not Allowed", pd.Title)
		assert.Equal(t, "Method not allowed", pd.Detail)
	})
}
