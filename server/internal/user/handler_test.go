package user

import (
	"context"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/krivolapovdev/trenerio/internal/auth"
	"github.com/krivolapovdev/trenerio/internal/db"
	pkgerrors "github.com/krivolapovdev/trenerio/internal/shared/errors"
	"github.com/krivolapovdev/trenerio/internal/shared/harness"
	"github.com/krivolapovdev/trenerio/internal/shared/response"
	"github.com/stretchr/testify/assert"
)

type mockUserService struct {
	deleteUserFn func(ctx context.Context, jwtUser auth.JwtUser) error
}

func (m *mockUserService) GetOrCreateUserFromOAuth2(ctx context.Context, provider db.UsersModuleOauth2Provider, providerID, email string) (response.UserResponse, error) {
	return response.UserResponse{}, nil
}

func (m *mockUserService) ExistsByID(ctx context.Context, id uuid.UUID) (bool, error) {
	return true, nil
}

func (m *mockUserService) DeleteUser(ctx context.Context, jwtUser auth.JwtUser) error {
	if m.deleteUserFn != nil {
		return m.deleteUserFn(ctx, jwtUser)
	}
	return nil
}

func setupUserRouter(svc userService, user auth.JwtUser) *gin.Engine {
	return harness.SetupTestRouter(user, func(rg *gin.RouterGroup) {
		NewHandler(svc).RegisterRoutes(rg)
	})
}

func TestUserHandler_DeleteMyAccount(t *testing.T) {
	testUser := auth.JwtUser{ID: uuid.New(), Email: "user@example.com"}

	t.Run("Unauthorized", func(t *testing.T) {
		r := setupUserRouter(&mockUserService{}, auth.JwtUser{})
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodDelete, "/api/v1/users/me", nil)
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusUnauthorized, w.Code)
	})

	t.Run("Success", func(t *testing.T) {
		called := false
		mockSvc := &mockUserService{
			deleteUserFn: func(ctx context.Context, jwtUser auth.JwtUser) error {
				assert.Equal(t, testUser.ID, jwtUser.ID)
				called = true
				return nil
			},
		}

		r := setupUserRouter(mockSvc, testUser)
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodDelete, "/api/v1/users/me", nil)
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusNoContent, w.Code)
		assert.True(t, called)
	})

	t.Run("NotFound", func(t *testing.T) {
		mockSvc := &mockUserService{
			deleteUserFn: func(ctx context.Context, jwtUser auth.JwtUser) error {
				return pkgerrors.NewNotFound("OAuth2User", jwtUser.ID, jwtUser.ID)
			},
		}

		r := setupUserRouter(mockSvc, testUser)
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodDelete, "/api/v1/users/me", nil)
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusNotFound, w.Code)
	})

	t.Run("InternalServerError", func(t *testing.T) {
		mockSvc := &mockUserService{
			deleteUserFn: func(ctx context.Context, jwtUser auth.JwtUser) error {
				return assert.AnError
			},
		}

		r := setupUserRouter(mockSvc, testUser)
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodDelete, "/api/v1/users/me", nil)
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusInternalServerError, w.Code)
	})
}
