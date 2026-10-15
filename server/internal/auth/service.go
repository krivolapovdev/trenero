package auth

import (
	"context"

	"github.com/krivolapovdev/trenerio/internal/db"
	"github.com/krivolapovdev/trenerio/internal/user"
	pkgerrors "github.com/krivolapovdev/trenerio/pkg/errors"
	"github.com/krivolapovdev/trenerio/pkg/security"
	"google.golang.org/api/idtoken"
)

type AuthService struct {
	userService    *user.UserService
	tokenProvider  *security.TokenProvider
	googleClientID string
}

func NewAuthService(userService *user.UserService, tokenProvider *security.TokenProvider, googleClientID string) *AuthService {
	return &AuthService{
		userService:    userService,
		tokenProvider:  tokenProvider,
		googleClientID: googleClientID,
	}
}

func (s *AuthService) LoginGoogle(ctx context.Context, token string) (LoginResponse, error) {
	payload, err := idtoken.Validate(ctx, token, s.googleClientID)
	if err != nil {
		return LoginResponse{}, &pkgerrors.BadRequestError{Message: "Invalid or expired Google identity token"}
	}

	providerID := payload.Subject
	if providerID == "" {
		return LoginResponse{}, &pkgerrors.BadRequestError{Message: "Google identity token does not contain a subject"}
	}

	emailVal, ok := payload.Claims["email"]
	if !ok {
		return LoginResponse{}, &pkgerrors.BadRequestError{Message: "Google identity token does not contain an email"}
	}
	email, ok := emailVal.(string)
	if !ok || email == "" {
		return LoginResponse{}, &pkgerrors.BadRequestError{Message: "Google identity token does not contain an email"}
	}

	u, err := s.userService.GetOrCreateUserFromOAuth2(ctx, db.UsersModuleOauth2ProviderGOOGLE, providerID, email)
	if err != nil {
		return LoginResponse{}, err
	}

	jwtUser := security.JwtUser{
		ID:    u.ID,
		Email: u.Email,
	}

	accessToken, err := s.tokenProvider.GenerateAccessToken(jwtUser)
	if err != nil {
		return LoginResponse{}, err
	}
	refreshToken, err := s.tokenProvider.GenerateRefreshToken(jwtUser)
	if err != nil {
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

func (s *AuthService) LoginReviewer(ctx context.Context, reviewerKey string) (LoginResponse, error) {
	if !s.tokenProvider.ValidateReviewerKey(reviewerKey) {
		return LoginResponse{}, &pkgerrors.BadRequestError{Message: "Invalid reviewer key"}
	}

	u, err := s.userService.GetOrCreateUserFromOAuth2(ctx, db.UsersModuleOauth2ProviderGOOGLE, "REVIEWER", "REVIEWER@TRENERIO.RU")
	if err != nil {
		return LoginResponse{}, err
	}

	jwtUser := security.JwtUser{
		ID:    u.ID,
		Email: u.Email,
	}

	accessToken, err := s.tokenProvider.GenerateAccessToken(jwtUser)
	if err != nil {
		return LoginResponse{}, err
	}
	refreshToken, err := s.tokenProvider.GenerateRefreshToken(jwtUser)
	if err != nil {
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

func (s *AuthService) RefreshTokens(ctx context.Context, refreshToken string) (JwtResponse, error) {
	if !s.tokenProvider.IsTokenValid(refreshToken, "REFRESH") {
		return JwtResponse{}, &pkgerrors.BadRequestError{Message: "Invalid or expired refresh token"}
	}

	jwtUser, err := s.tokenProvider.ExtractUser(refreshToken)
	if err != nil {
		return JwtResponse{}, &pkgerrors.BadRequestError{Message: "Invalid or expired refresh token"}
	}

	exists, err := s.userService.ExistsByID(ctx, jwtUser.ID)
	if err != nil {
		return JwtResponse{}, err
	}
	if !exists {
		return JwtResponse{}, &pkgerrors.BadRequestError{Message: "Invalid or expired refresh token"}
	}

	accessToken, err := s.tokenProvider.GenerateAccessToken(jwtUser)
	if err != nil {
		return JwtResponse{}, err
	}
	newRefreshToken, err := s.tokenProvider.GenerateRefreshToken(jwtUser)
	if err != nil {
		return JwtResponse{}, err
	}

	return JwtResponse{
		AccessToken:  accessToken,
		RefreshToken: newRefreshToken,
	}, nil
}
