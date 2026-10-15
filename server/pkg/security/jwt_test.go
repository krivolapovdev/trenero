package security

import (
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestTokenProvider_AccessAndRefreshToken(t *testing.T) {
	secret := "test-super-secret-key-that-is-long-enough-32-bytes"
	reviewerKey := "valid-reviewer-secret"
	provider := NewTokenProvider(secret, time.Hour, 24*time.Hour, reviewerKey)

	user := JwtUser{
		ID:    uuid.New(),
		Email: "test@example.com",
	}

	accessToken, err := provider.GenerateAccessToken(user)
	require.NoError(t, err)
	assert.NotEmpty(t, accessToken)

	refreshToken, err := provider.GenerateRefreshToken(user)
	require.NoError(t, err)
	assert.NotEmpty(t, refreshToken)

	assert.True(t, provider.IsTokenValid(accessToken, "ACCESS"))
	assert.False(t, provider.IsTokenValid(accessToken, "REFRESH"))
	assert.True(t, provider.IsTokenValid(refreshToken, "REFRESH"))
	assert.False(t, provider.IsTokenValid(refreshToken, "ACCESS"))

	extracted, err := provider.ExtractUser(accessToken)
	require.NoError(t, err)
	assert.Equal(t, user.ID, extracted.ID)
	assert.Equal(t, user.Email, extracted.Email)

	extractedRefresh, err := provider.ExtractUser(refreshToken)
	require.NoError(t, err)
	assert.Equal(t, user.ID, extractedRefresh.ID)
	assert.Equal(t, user.Email, extractedRefresh.Email)
}

func TestTokenProvider_InvalidTokens(t *testing.T) {
	provider := NewTokenProvider("key1-super-secret-key-32-bytes-long", time.Hour, time.Hour, "rev")
	otherProvider := NewTokenProvider("key2-super-secret-key-32-bytes-long", time.Hour, time.Hour, "rev")

	user := JwtUser{
		ID:    uuid.New(),
		Email: "user@example.com",
	}

	tokenFromOther, err := otherProvider.GenerateAccessToken(user)
	require.NoError(t, err)

	assert.False(t, provider.IsTokenValid(tokenFromOther, "ACCESS"))
	_, err = provider.ExtractUser(tokenFromOther)
	assert.Error(t, err)

	assert.False(t, provider.IsTokenValid("not-a-token", "ACCESS"))
	_, err = provider.ExtractUser("not-a-token")
	assert.Error(t, err)
}

func TestTokenProvider_ExpiredToken(t *testing.T) {
	provider := NewTokenProvider("key-super-secret-key-32-bytes-long", -time.Minute, -time.Minute, "rev")
	user := JwtUser{
		ID:    uuid.New(),
		Email: "user@example.com",
	}

	token, err := provider.GenerateAccessToken(user)
	require.NoError(t, err)

	assert.False(t, provider.IsTokenValid(token, "ACCESS"))
	_, err = provider.ExtractUser(token)
	assert.Error(t, err)
}

func TestTokenProvider_ValidateReviewerKey(t *testing.T) {
	provider := NewTokenProvider("key-super-secret-key-32-bytes-long", time.Hour, time.Hour, "secret-reviewer-key")

	assert.True(t, provider.ValidateReviewerKey("secret-reviewer-key"))
	assert.False(t, provider.ValidateReviewerKey("wrong-key"))
	assert.False(t, provider.ValidateReviewerKey(""))

	providerNoReviewer := NewTokenProvider("key-super-secret-key-32-bytes-long", time.Hour, time.Hour, "")
	assert.False(t, providerNoReviewer.ValidateReviewerKey("secret-reviewer-key"))
}
