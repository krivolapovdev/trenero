package auth

import (
	"context"
	"github.com/krivolapovdev/trenerio/pkg/response"

	"github.com/krivolapovdev/trenerio/pkg/logger"
	"github.com/krivolapovdev/trenerio/pkg/security"
)

func generateLoginResponse(ctx context.Context, tp *security.TokenProvider, u response.UserResponse, loginType string) (response.LoginResponse, error) {
	jwtUser := security.JwtUser{
		ID:    u.ID,
		Email: u.Email,
	}

	accessToken, refreshToken, err := tp.GenerateTokenPair(jwtUser)
	if err != nil {
		logger.ErrorContext(ctx, "Failed to generate tokens for "+loginType+" login", "error", err, "user_id", u.ID.String())
		return response.LoginResponse{}, err
	}

	return response.LoginResponse{
		User: u,
		JwtTokens: response.JwtResponse{
			AccessToken:  accessToken,
			RefreshToken: refreshToken,
		},
	}, nil
}
