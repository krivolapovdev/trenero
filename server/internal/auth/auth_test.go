package auth

import (
	"context"
	"github.com/krivolapovdev/trenerio/pkg/response"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/krivolapovdev/trenerio/internal/db"
	pkgerrors "github.com/krivolapovdev/trenerio/pkg/errors"
	"github.com/krivolapovdev/trenerio/pkg/security"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestAuthService_LoginReviewer(t *testing.T) {
	reviewerKey := "super-secret-reviewer-key"
	tokenProvider := security.NewTokenProvider("test-jwt-secret-key-at-least-32-chars", time.Hour, 24*time.Hour, reviewerKey)
	testUserID := uuid.New()

	mockGetOrCreate := func(ctx context.Context, provider db.UsersModuleOauth2Provider, providerID, email string) (response.UserResponse, error) {
		assert.Equal(t, ReviewerProviderID, providerID)
		assert.Equal(t, ReviewerEmail, email)
		return response.UserResponse{
			ID:    testUserID,
			Email: email,
		}, nil
	}

	service := NewService(mockGetOrCreate, nil, tokenProvider, "dummy-google-client-id")
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
	tokenProvider := security.NewTokenProvider("test-jwt-secret-key-at-least-32-chars", time.Hour, 24*time.Hour, reviewerKey)
	testUserID := uuid.New()

	// Invalid refresh token
	service := NewService(nil, nil, tokenProvider, "dummy-client-id")
	ctx := context.Background()

	_, err := service.RefreshTokens(ctx, "invalid-token-string")
	require.Error(t, err)

	// Valid refresh token, user does not exist
	refreshToken, err := tokenProvider.GenerateRefreshToken(security.JwtUser{
		ID:    testUserID,
		Email: "trainer@test.com",
	})
	require.NoError(t, err)

	mockUserExistsFalse := func(ctx context.Context, id uuid.UUID) (bool, error) {
		return false, nil
	}
	service = NewService(nil, mockUserExistsFalse, tokenProvider, "dummy-client-id")

	_, err = service.RefreshTokens(ctx, refreshToken)
	require.Error(t, err)

	// Valid refresh token, user exists
	mockUserExistsTrue := func(ctx context.Context, id uuid.UUID) (bool, error) {
		return true, nil
	}
	service = NewService(nil, mockUserExistsTrue, tokenProvider, "dummy-client-id")

	jwtResp, err := service.RefreshTokens(ctx, refreshToken)
	require.NoError(t, err)
	assert.NotEmpty(t, jwtResp.AccessToken)
	assert.NotEmpty(t, jwtResp.RefreshToken)
}
