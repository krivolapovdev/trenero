package auth

import (
	"context"

	"github.com/krivolapovdev/trenerio/pkg/logger"
	"github.com/krivolapovdev/trenerio/pkg/models"
	"github.com/krivolapovdev/trenerio/pkg/security"
)

func generateLoginResponse(ctx context.Context, tp *security.TokenProvider, u models.UserResponse, loginType string) (LoginResponse, error) {
	jwtUser := security.JwtUser{
		ID:    u.ID,
		Email: u.Email,
	}

	accessToken, refreshToken, err := tp.GenerateTokenPair(jwtUser)
	if err != nil {
		logger.ErrorContext(ctx, "Failed to generate tokens for "+loginType+" login", "error", err, "user_id", u.ID.String())
		return LoginResponse{}, err
	}

	return LoginResponse{
		User: u,
		JwtTokens: JwtResponse{
			AccessToken:  accessToken,
			RefreshToken: refreshToken,
		},
	}, nil
}
