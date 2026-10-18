package auth

import (
	"bytes"
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	pkgerrors "github.com/krivolapovdev/trenerio/pkg/errors"
	"github.com/krivolapovdev/trenerio/pkg/models"
	"github.com/krivolapovdev/trenerio/pkg/types"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

type mockAuthService struct {
	loginGoogleFn   func(ctx context.Context, token string) (LoginResponse, error)
	refreshTokensFn func(ctx context.Context, refreshToken string) (models.JwtResponse, error)
	loginReviewerFn func(ctx context.Context, reviewerKey string) (LoginResponse, error)
}

func (m *mockAuthService) LoginGoogle(ctx context.Context, token string) (LoginResponse, error) {
	if m.loginGoogleFn != nil {
		return m.loginGoogleFn(ctx, token)
	}
	return LoginResponse{}, nil
}

func (m *mockAuthService) RefreshTokens(ctx context.Context, refreshToken string) (models.JwtResponse, error) {
	if m.refreshTokensFn != nil {
		return m.refreshTokensFn(ctx, refreshToken)
	}
	return models.JwtResponse{}, nil
}

func (m *mockAuthService) LoginReviewer(ctx context.Context, reviewerKey string) (LoginResponse, error) {
	if m.loginReviewerFn != nil {
		return m.loginReviewerFn(ctx, reviewerKey)
	}
	return LoginResponse{}, nil
}

func setupAuthRouter(svc authService) *gin.Engine {
	gin.SetMode(gin.TestMode)
	r := gin.New()
	h := NewHandler(svc)
	h.RegisterRoutes(r.Group("/api/v1"))
	return r
}

func TestAuthHandler_GoogleLogin(t *testing.T) {
	t.Run("Success", func(t *testing.T) {
		expectedResp := LoginResponse{
			User: models.UserResponse{
				ID:    uuid.New(),
				Email: "teacher@trenerio.ru",
			},
			JwtTokens: JwtResponse{
				AccessToken:  "access-123",
				RefreshToken: "refresh-123",
			},
		}

		mockSvc := &mockAuthService{
			loginGoogleFn: func(ctx context.Context, token string) (LoginResponse, error) {
				assert.Equal(t, "google-token-xyz", token)
				return expectedResp, nil
			},
		}

		r := setupAuthRouter(mockSvc)
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodPost, "/api/v1/oauth2/google", bytes.NewBufferString(`{"token":"google-token-xyz"}`))
		req.Header.Set("Content-Type", "application/json")
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusOK, w.Code)
		var actualResp LoginResponse
		err := json.Unmarshal(w.Body.Bytes(), &actualResp)
		require.NoError(t, err)
		assert.Equal(t, expectedResp.User.Email, actualResp.User.Email)
		assert.Equal(t, expectedResp.JwtTokens.AccessToken, actualResp.JwtTokens.AccessToken)
	})

	t.Run("InvalidJSON", func(t *testing.T) {
		mockSvc := &mockAuthService{}
		r := setupAuthRouter(mockSvc)
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodPost, "/api/v1/oauth2/google", bytes.NewBufferString(`invalid`))
		req.Header.Set("Content-Type", "application/json")
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusBadRequest, w.Code)
	})

	t.Run("ServiceError", func(t *testing.T) {
		mockSvc := &mockAuthService{
			loginGoogleFn: func(ctx context.Context, token string) (LoginResponse, error) {
				return LoginResponse{}, pkgerrors.NewBadRequest("token rejected")
			},
		}
		r := setupAuthRouter(mockSvc)
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodPost, "/api/v1/oauth2/google", bytes.NewBufferString(`{"token":"bad-token"}`))
		req.Header.Set("Content-Type", "application/json")
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusBadRequest, w.Code)
	})

	t.Run("InternalServerError", func(t *testing.T) {
		mockSvc := &mockAuthService{
			loginGoogleFn: func(ctx context.Context, token string) (LoginResponse, error) {
				return LoginResponse{}, assert.AnError
			},
		}
		r := setupAuthRouter(mockSvc)
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodPost, "/api/v1/oauth2/google", bytes.NewBufferString(`{"token":"crash-token"}`))
		req.Header.Set("Content-Type", "application/json")
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusInternalServerError, w.Code)
	})
}

func TestAuthHandler_RefreshTokens(t *testing.T) {
	t.Run("Success", func(t *testing.T) {
		expectedTokens := models.JwtResponse{
			AccessToken:  "new-access",
			RefreshToken: "new-refresh",
		}

		mockSvc := &mockAuthService{
			refreshTokensFn: func(ctx context.Context, refreshToken string) (models.JwtResponse, error) {
				assert.Equal(t, "old-refresh", refreshToken)
				return expectedTokens, nil
			},
		}

		r := setupAuthRouter(mockSvc)
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodPost, "/api/v1/jwt/refresh", bytes.NewBufferString(`{"refreshToken":"old-refresh"}`))
		req.Header.Set("Content-Type", "application/json")
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusOK, w.Code)
		var actualTokens models.JwtResponse
		err := json.Unmarshal(w.Body.Bytes(), &actualTokens)
		require.NoError(t, err)
		assert.Equal(t, expectedTokens.AccessToken, actualTokens.AccessToken)
	})

	t.Run("InvalidJSON", func(t *testing.T) {
		mockSvc := &mockAuthService{}
		r := setupAuthRouter(mockSvc)
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodPost, "/api/v1/jwt/refresh", bytes.NewBufferString(`malformed`))
		req.Header.Set("Content-Type", "application/json")
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusBadRequest, w.Code)
	})

	t.Run("Unauthorized_ExpiredOrInvalidToken", func(t *testing.T) {
		mockSvc := &mockAuthService{
			refreshTokensFn: func(ctx context.Context, refreshToken string) (models.JwtResponse, error) {
				return models.JwtResponse{}, pkgerrors.NewUnauthorized("Invalid or expired refresh token")
			},
		}
		r := setupAuthRouter(mockSvc)
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodPost, "/api/v1/jwt/refresh", bytes.NewBufferString(`{"refreshToken":"expired"}`))
		req.Header.Set("Content-Type", "application/json")
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusUnauthorized, w.Code)
	})

	t.Run("InternalServerError", func(t *testing.T) {
		mockSvc := &mockAuthService{
			refreshTokensFn: func(ctx context.Context, refreshToken string) (models.JwtResponse, error) {
				return models.JwtResponse{}, assert.AnError
			},
		}
		r := setupAuthRouter(mockSvc)
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodPost, "/api/v1/jwt/refresh", bytes.NewBufferString(`{"refreshToken":"any"}`))
		req.Header.Set("Content-Type", "application/json")
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusInternalServerError, w.Code)
	})
}

func TestAuthHandler_ReviewerLogin(t *testing.T) {
	t.Run("MissingHeader", func(t *testing.T) {
		mockSvc := &mockAuthService{}
		r := setupAuthRouter(mockSvc)
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodPost, "/api/v1/reviewer/login", nil)
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusUnauthorized, w.Code)
	})

	t.Run("Success", func(t *testing.T) {
		expectedResp := LoginResponse{
			User: models.UserResponse{
				ID:    uuid.New(),
				Email: ReviewerEmail,
			},
		}

		mockSvc := &mockAuthService{
			loginReviewerFn: func(ctx context.Context, reviewerKey string) (LoginResponse, error) {
				assert.Equal(t, "secret-key", reviewerKey)
				return expectedResp, nil
			},
		}

		r := setupAuthRouter(mockSvc)
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodPost, "/api/v1/reviewer/login", nil)
		req.Header.Set(types.HeaderXReviewerKey, "secret-key")
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusOK, w.Code)
	})

	t.Run("Unauthorized_InvalidKey", func(t *testing.T) {
		mockSvc := &mockAuthService{
			loginReviewerFn: func(ctx context.Context, reviewerKey string) (LoginResponse, error) {
				return LoginResponse{}, pkgerrors.NewUnauthorized("Invalid reviewer key")
			},
		}

		r := setupAuthRouter(mockSvc)
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodPost, "/api/v1/reviewer/login", nil)
		req.Header.Set(types.HeaderXReviewerKey, "wrong-key")
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusUnauthorized, w.Code)
	})

	t.Run("InternalServerError", func(t *testing.T) {
		mockSvc := &mockAuthService{
			loginReviewerFn: func(ctx context.Context, reviewerKey string) (LoginResponse, error) {
				return LoginResponse{}, assert.AnError
			},
		}

		r := setupAuthRouter(mockSvc)
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodPost, "/api/v1/reviewer/login", nil)
		req.Header.Set(types.HeaderXReviewerKey, "crash-key")
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusInternalServerError, w.Code)
	})
}
