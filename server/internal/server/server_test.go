package server

import (
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/krivolapovdev/trenerio/internal/auth"
	"github.com/krivolapovdev/trenerio/internal/db"
	pkgerrors "github.com/krivolapovdev/trenerio/internal/shared/errors"
	"github.com/krivolapovdev/trenerio/internal/shared/response"
	"github.com/krivolapovdev/trenerio/internal/user"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func init() {
	gin.SetMode(gin.TestMode)
}

func TestSwaggerEndpoint(t *testing.T) {
	tokenProvider := auth.NewTokenProvider("super-secret-key-32-bytes-long!", time.Hour, 24*time.Hour, "reviewer-key")
	srv := NewServer(tokenProvider, []string{"*"}, nil, nil, nil, nil, nil, nil, nil, nil)

	w := httptest.NewRecorder()
	req := httptest.NewRequest(http.MethodGet, "/swagger/doc.json", nil)
	srv.Engine().ServeHTTP(w, req)

	assert.Equal(t, http.StatusOK, w.Code)
	assert.Contains(t, w.Body.String(), `"title": "Trenerio API"`)
	assert.Contains(t, w.Body.String(), `"/api/v1/groups"`)
}

func TestHealthEndpoint(t *testing.T) {
	tokenProvider := auth.NewTokenProvider("super-secret-key-32-bytes-long!", time.Hour, 24*time.Hour, "reviewer-key")
	srv := NewServer(tokenProvider, []string{"*"}, nil, nil, nil, nil, nil, nil, nil, nil)

	w := httptest.NewRecorder()
	req := httptest.NewRequest(http.MethodGet, "/health", nil)
	srv.Engine().ServeHTTP(w, req)

	assert.Equal(t, http.StatusOK, w.Code)
	assert.Equal(t, "OK", w.Body.String())
}

func TestNoRouteAndNoMethod(t *testing.T) {
	tokenProvider := auth.NewTokenProvider("super-secret-key-32-bytes-long!", time.Hour, 24*time.Hour, "reviewer-key")
	srv := NewServer(tokenProvider, []string{"*"}, nil, nil, nil, nil, nil, nil, nil, nil)

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

type testAuthService struct {
	loginReviewerFn func(ctx context.Context, reviewerKey string) (response.LoginResponse, error)
}

func (m *testAuthService) LoginGoogle(ctx context.Context, token string) (response.LoginResponse, error) {
	return response.LoginResponse{}, nil
}

func (m *testAuthService) RefreshTokens(ctx context.Context, refreshToken string) (response.JwtResponse, error) {
	return response.JwtResponse{}, nil
}

func (m *testAuthService) LoginReviewer(ctx context.Context, reviewerKey string) (response.LoginResponse, error) {
	if m.loginReviewerFn != nil {
		return m.loginReviewerFn(ctx, reviewerKey)
	}
	return response.LoginResponse{}, nil
}

type testUserService struct {
	deleteUserFn func(ctx context.Context, jwtUser auth.JwtUser) error
}

func (m *testUserService) GetOrCreateUserFromOAuth2(ctx context.Context, provider db.UsersModuleOauth2Provider, providerID, email string) (response.UserResponse, error) {
	return response.UserResponse{}, nil
}

func (m *testUserService) ExistsByID(ctx context.Context, id uuid.UUID) (bool, error) {
	return true, nil
}

func (m *testUserService) DeleteUser(ctx context.Context, jwtUser auth.JwtUser) error {
	if m.deleteUserFn != nil {
		return m.deleteUserFn(ctx, jwtUser)
	}
	return nil
}

func TestServer_AuthAndProtectedRoutes(t *testing.T) {
	tokenProvider := auth.NewTokenProvider("super-secret-key-32-bytes-long!", time.Hour, 24*time.Hour, "reviewer-key")
	testUser := auth.JwtUser{ID: uuid.New(), Email: "test@trenerio.ru"}

	authHandler := auth.NewHandler(&testAuthService{
		loginReviewerFn: func(ctx context.Context, reviewerKey string) (response.LoginResponse, error) {
			if reviewerKey == "valid-key" {
				acc, ref, err := tokenProvider.GenerateTokenPair(testUser)
				if err != nil {
					return response.LoginResponse{}, err
				}
				return response.LoginResponse{
					User: response.UserResponse{ID: testUser.ID, Email: testUser.Email},
					JwtTokens: response.JwtResponse{
						AccessToken:  acc,
						RefreshToken: ref,
					},
				}, nil
			}
			return response.LoginResponse{}, pkgerrors.NewUnauthorized("Invalid reviewer key")
		},
	})

	userHandler := user.NewHandler(&testUserService{
		deleteUserFn: func(ctx context.Context, u auth.JwtUser) error {
			assert.Equal(t, testUser.ID, u.ID)
			return nil
		},
	})

	srv := NewServer(tokenProvider, []string{"https://trenerio.ru"}, authHandler, userHandler, nil, nil, nil, nil, nil, nil)

	t.Run("PublicRoute_ReviewerLogin_Success", func(t *testing.T) {
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodPost, "/api/v1/reviewer/login", nil)
		req.Header.Set("X-Reviewer-Key", "valid-key")
		srv.Engine().ServeHTTP(w, req)

		assert.Equal(t, http.StatusOK, w.Code)
		var resp response.LoginResponse
		err := json.Unmarshal(w.Body.Bytes(), &resp)
		require.NoError(t, err)
		assert.Equal(t, testUser.Email, resp.User.Email)
		assert.NotEmpty(t, resp.JwtTokens.AccessToken)
	})

	t.Run("ProtectedRoute_WithoutToken_ReturnsUnauthorized", func(t *testing.T) {
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodDelete, "/api/v1/users/me", nil)
		srv.Engine().ServeHTTP(w, req)

		assert.Equal(t, http.StatusUnauthorized, w.Code)
		var pd pkgerrors.ProblemDetail
		err := json.Unmarshal(w.Body.Bytes(), &pd)
		require.NoError(t, err)
		assert.Equal(t, "Unauthorized", pd.Title)
	})

	t.Run("ProtectedRoute_WithInvalidTokenFormat_ReturnsUnauthorized", func(t *testing.T) {
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodDelete, "/api/v1/users/me", nil)
		req.Header.Set("Authorization", "InvalidHeaderFormat")
		srv.Engine().ServeHTTP(w, req)

		assert.Equal(t, http.StatusUnauthorized, w.Code)
	})

	t.Run("ProtectedRoute_WithInvalidToken_ReturnsUnauthorized", func(t *testing.T) {
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodDelete, "/api/v1/users/me", nil)
		req.Header.Set("Authorization", "Bearer invalid.jwt.token")
		srv.Engine().ServeHTTP(w, req)

		assert.Equal(t, http.StatusUnauthorized, w.Code)
	})

	t.Run("ProtectedRoute_WithValidToken_Success", func(t *testing.T) {
		accessToken, _, err := tokenProvider.GenerateTokenPair(testUser)
		require.NoError(t, err)

		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodDelete, "/api/v1/users/me", nil)
		req.Header.Set("Authorization", "Bearer "+accessToken)
		srv.Engine().ServeHTTP(w, req)

		assert.Equal(t, http.StatusNoContent, w.Code)
	})
}

func TestServer_MiddlewareIntegration(t *testing.T) {
	tokenProvider := auth.NewTokenProvider("super-secret-key-32-bytes-long!", time.Hour, 24*time.Hour, "reviewer-key")
	srv := NewServer(tokenProvider, []string{"https://app.trenerio.ru"}, nil, nil, nil, nil, nil, nil, nil, nil)

	t.Run("RequestIDMiddleware_PreservesCustomID", func(t *testing.T) {
		customID := "custom-request-id-12345"
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodGet, "/health", nil)
		req.Header.Set("X-Request-ID", customID)
		srv.Engine().ServeHTTP(w, req)

		assert.Equal(t, http.StatusOK, w.Code)
		assert.Equal(t, customID, w.Header().Get("X-Request-ID"))
	})

	t.Run("RequestIDMiddleware_GeneratesNewIDWhenMissing", func(t *testing.T) {
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodGet, "/health", nil)
		srv.Engine().ServeHTTP(w, req)

		assert.Equal(t, http.StatusOK, w.Code)
		generatedID := w.Header().Get("X-Request-ID")
		assert.NotEmpty(t, generatedID)
		_, err := uuid.Parse(generatedID)
		assert.NoError(t, err, "Generated request ID should be a valid UUID")
	})

	t.Run("CorsMiddleware_PreflightOptions", func(t *testing.T) {
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodOptions, "/health", nil)
		req.Header.Set("Origin", "https://app.trenerio.ru")
		req.Header.Set("Access-Control-Request-Method", "POST")
		req.Header.Set("Access-Control-Request-Headers", "Authorization, Content-Type")
		srv.Engine().ServeHTTP(w, req)

		assert.Equal(t, http.StatusNoContent, w.Code)
		assert.Equal(t, "https://app.trenerio.ru", w.Header().Get("Access-Control-Allow-Origin"))
		assert.Contains(t, w.Header().Get("Access-Control-Allow-Methods"), "POST")
	})

	t.Run("RecoveryMiddleware_CatchesPanic", func(t *testing.T) {
		// Register a temporary panic route on engine
		srv.Engine().GET("/test-panic", func(c *gin.Context) {
			panic("unexpected internal crash")
		})

		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodGet, "/test-panic", nil)
		srv.Engine().ServeHTTP(w, req)

		assert.Equal(t, http.StatusInternalServerError, w.Code)
		var pd pkgerrors.ProblemDetail
		err := json.Unmarshal(w.Body.Bytes(), &pd)
		require.NoError(t, err)
		assert.Equal(t, "Internal Server Error", pd.Title)
	})

	t.Run("ErrorHandlerMiddleware_HandlesGinError", func(t *testing.T) {
		srv.Engine().GET("/test-error", func(c *gin.Context) {
			_ = c.Error(pkgerrors.NewBadRequest("invalid test parameter"))
		})

		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodGet, "/test-error", nil)
		srv.Engine().ServeHTTP(w, req)

		assert.Equal(t, http.StatusBadRequest, w.Code)
		var pd pkgerrors.ProblemDetail
		err := json.Unmarshal(w.Body.Bytes(), &pd)
		require.NoError(t, err)
		assert.Equal(t, "Bad Request", pd.Title)
		assert.Equal(t, "invalid test parameter", pd.Detail)
	})
}
