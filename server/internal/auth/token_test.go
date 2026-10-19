package auth

import (
	"context"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/krivolapovdev/trenerio/internal/db"
	pkgerrors "github.com/krivolapovdev/trenerio/internal/shared/errors"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

type mockUserProvider struct {
	getOrCreateUserFromOAuth2 func(ctx context.Context, provider db.UsersModuleOauth2Provider, providerID, email string) (UserResponse, error)
	existsByID                func(ctx context.Context, id uuid.UUID) (bool, error)
}

func (m *mockUserProvider) GetOrCreateUserFromOAuth2(ctx context.Context, provider db.UsersModuleOauth2Provider, providerID, email string) (UserResponse, error) {
	if m.getOrCreateUserFromOAuth2 != nil {
		return m.getOrCreateUserFromOAuth2(ctx, provider, providerID, email)
	}
	return UserResponse{}, nil
}

func (m *mockUserProvider) ExistsByID(ctx context.Context, id uuid.UUID) (bool, error) {
	if m.existsByID != nil {
		return m.existsByID(ctx, id)
	}
	return false, nil
}

func TestAuthService_LoginReviewer(t *testing.T) {
	reviewerKey := "super-secret-reviewer-key"
	tokenProvider := NewTokenProvider("test-jwt-secret-key-at-least-32-chars", time.Hour, 24*time.Hour, reviewerKey)
	testUserID := uuid.New()

	mockProvider := &mockUserProvider{
		getOrCreateUserFromOAuth2: func(ctx context.Context, provider db.UsersModuleOauth2Provider, providerID, email string) (UserResponse, error) {
			assert.Equal(t, ReviewerProviderID, providerID)
			assert.Equal(t, ReviewerEmail, email)
			return UserResponse{
				ID:    testUserID,
				Email: email,
			}, nil
		},
	}

	service := NewService(mockProvider, tokenProvider, "dummy-google-client-id")
	ctx := context.Background()

	// Invalid reviewer key
	_, err := service.LoginReviewer(ctx, "wrong-key")
	require.Error(t, err)
	var badReq *pkgerrors.BadRequestError
	require.ErrorAs(t, err, &badReq)
	assert.Equal(t, "Invalid reviewer key", badReq.Message)

	// Valid reviewer key
	resp, err := service.LoginReviewer(ctx, reviewerKey)
	require.NoError(t, err)
	assert.Equal(t, testUserID, resp.User.ID)
	assert.Equal(t, ReviewerEmail, resp.User.Email)
	assert.NotEmpty(t, resp.JwtTokens.AccessToken)
	assert.NotEmpty(t, resp.JwtTokens.RefreshToken)
}

func TestAuthService_RefreshTokens(t *testing.T) {
	reviewerKey := "reviewer-key"
	tokenProvider := NewTokenProvider("test-jwt-secret-key-at-least-32-chars", time.Hour, 24*time.Hour, reviewerKey)
	testUserID := uuid.New()

	// Invalid refresh token
	service := NewService(nil, tokenProvider, "dummy-client-id")
	ctx := context.Background()

	_, err := service.RefreshTokens(ctx, "invalid-token-string")
	require.Error(t, err)

	// Valid refresh token, user does not exist
	refreshToken, err := tokenProvider.GenerateRefreshToken(JwtUser{
		ID:    testUserID,
		Email: "trainer@test.com",
	})
	require.NoError(t, err)

	mockUserExistsFalse := &mockUserProvider{
		existsByID: func(ctx context.Context, id uuid.UUID) (bool, error) {
			return false, nil
		},
	}
	service = NewService(mockUserExistsFalse, tokenProvider, "dummy-client-id")

	_, err = service.RefreshTokens(ctx, refreshToken)
	require.Error(t, err)

	// Valid refresh token, user exists
	mockUserExistsTrue := &mockUserProvider{
		existsByID: func(ctx context.Context, id uuid.UUID) (bool, error) {
			return true, nil
		},
	}
	service = NewService(mockUserExistsTrue, tokenProvider, "dummy-client-id")

	jwtResp, err := service.RefreshTokens(ctx, refreshToken)
	require.NoError(t, err)
	assert.NotEmpty(t, jwtResp.AccessToken)
	assert.NotEmpty(t, jwtResp.RefreshToken)
}
