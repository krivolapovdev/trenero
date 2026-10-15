package server

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	pkgerrors "github.com/krivolapovdev/trenerio/pkg/errors"
	"github.com/krivolapovdev/trenerio/pkg/security"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func init() {
	gin.SetMode(gin.TestMode)
}

func TestCorsMiddleware(t *testing.T) {
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

func TestAuthMiddleware(t *testing.T) {
	tokenProvider := security.NewTokenProvider("super-secret-key-32-bytes-long!", time.Hour, 24*time.Hour, "reviewer-key")
	user := security.JwtUser{
		ID:    uuid.New(),
		Email: "teacher@trenero.org",
	}

	validAccessToken, err := tokenProvider.GenerateAccessToken(user)
	require.NoError(t, err)

	validRefreshToken, err := tokenProvider.GenerateRefreshToken(user)
	require.NoError(t, err)

	r := gin.New()
	r.Use(AuthMiddleware(tokenProvider))
	r.GET("/protected", func(c *gin.Context) {
		val, exists := c.Get("jwtUser")
		if !exists {
			c.Status(http.StatusInternalServerError)
			return
		}
		u := val.(security.JwtUser)
		c.JSON(http.StatusOK, gin.H{
			"id":    u.ID.String(),
			"email": u.Email,
		})
	})

	t.Run("MissingAuthorizationHeader", func(t *testing.T) {
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodGet, "/protected", nil)
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusUnauthorized, w.Code)
		var pd pkgerrors.ProblemDetail
		err := json.Unmarshal(w.Body.Bytes(), &pd)
		require.NoError(t, err)
		assert.Equal(t, "Unauthorized", pd.Title)
		assert.Equal(t, "Full authentication is required to access this resource", pd.Detail)
	})

	t.Run("InvalidBearerToken", func(t *testing.T) {
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodGet, "/protected", nil)
		req.Header.Set("Authorization", "Bearer invalid.jwt.token")
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusUnauthorized, w.Code)
	})

	t.Run("RefreshTokenUsedAsBearer", func(t *testing.T) {
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodGet, "/protected", nil)
		req.Header.Set("Authorization", "Bearer "+validRefreshToken)
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusUnauthorized, w.Code)
	})

	t.Run("ValidAccessToken", func(t *testing.T) {
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodGet, "/protected", nil)
		req.Header.Set("Authorization", "Bearer "+validAccessToken)
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusOK, w.Code)
		var res map[string]string
		err := json.Unmarshal(w.Body.Bytes(), &res)
		require.NoError(t, err)
		assert.Equal(t, user.ID.String(), res["id"])
		assert.Equal(t, user.Email, res["email"])
	})
}

func TestRecoveryMiddleware(t *testing.T) {
	r := gin.New()
	r.Use(RecoveryMiddleware())
	r.GET("/panic", func(c *gin.Context) {
		panic("something went completely wrong")
	})

	w := httptest.NewRecorder()
	req := httptest.NewRequest(http.MethodGet, "/panic", nil)
	r.ServeHTTP(w, req)

	assert.Equal(t, http.StatusInternalServerError, w.Code)
	var pd pkgerrors.ProblemDetail
	err := json.Unmarshal(w.Body.Bytes(), &pd)
	require.NoError(t, err)
	assert.Equal(t, "Internal Server Error", pd.Title)
	assert.Contains(t, pd.Detail, "something went completely wrong")
}

func TestRequestIDMiddleware(t *testing.T) {
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

func TestLoggingMiddleware(t *testing.T) {
	r := gin.New()
	r.Use(RequestIDMiddleware())
	r.Use(LoggingMiddleware())
	r.GET("/ok", func(c *gin.Context) {
		c.String(http.StatusOK, "success")
	})
	r.GET("/client-err", func(c *gin.Context) {
		c.String(http.StatusBadRequest, "bad input")
	})
	r.GET("/server-err", func(c *gin.Context) {
		c.String(http.StatusInternalServerError, "error")
	})

	t.Run("SuccessLogging", func(t *testing.T) {
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodGet, "/ok", nil)
		r.ServeHTTP(w, req)
		assert.Equal(t, http.StatusOK, w.Code)
	})

	t.Run("ClientErrorLogging", func(t *testing.T) {
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodGet, "/client-err", nil)
		r.ServeHTTP(w, req)
		assert.Equal(t, http.StatusBadRequest, w.Code)
	})

	t.Run("ServerErrorLogging", func(t *testing.T) {
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodGet, "/server-err", nil)
		r.ServeHTTP(w, req)
		assert.Equal(t, http.StatusInternalServerError, w.Code)
	})
}
