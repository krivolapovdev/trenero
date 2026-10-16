package auth

import (
	"context"

	"github.com/google/uuid"
	"github.com/krivolapovdev/trenerio/internal/db"
	pkgerrors "github.com/krivolapovdev/trenerio/pkg/errors"
	"github.com/krivolapovdev/trenerio/pkg/logger"
	"github.com/krivolapovdev/trenerio/pkg/models"
	"github.com/krivolapovdev/trenerio/pkg/security"
	"google.golang.org/api/idtoken"
)

type GetOrCreateUserFunc func(ctx context.Context, provider db.UsersModuleOauth2Provider, providerID, email string) (models.UserResponse, error)
type UserExistsByIDFunc func(ctx context.Context, id uuid.UUID) (bool, error)

type Service struct {
	getOrCreateUser GetOrCreateUserFunc
	userExistsByID  UserExistsByIDFunc
	tokenProvider   *security.TokenProvider
	googleClientID  string
}

func NewService(
	getOrCreateUser GetOrCreateUserFunc,
	userExistsByID UserExistsByIDFunc,
	tokenProvider *security.TokenProvider,
	googleClientID string,
) *Service {
	return &Service{
		getOrCreateUser: getOrCreateUser,
		userExistsByID:  userExistsByID,
		tokenProvider:   tokenProvider,
		googleClientID:  googleClientID,
	}
}

func (s *Service) LoginGoogle(ctx context.Context, token string) (LoginResponse, error) {
	logger.InfoContext(ctx, "Processing Google login")
	payload, err := idtoken.Validate(ctx, token, s.googleClientID)
	if err != nil {
		logger.WarnContext(ctx, "Failed to validate Google identity token", "error", err)
		return LoginResponse{}, &pkgerrors.BadRequestError{Message: "Invalid or expired Google identity token"}
	}

	providerID := payload.Subject
	if providerID == "" {
		logger.WarnContext(ctx, "Google identity token does not contain a subject")
		return LoginResponse{}, &pkgerrors.BadRequestError{Message: "Google identity token does not contain a subject"}
	}

	emailVal, ok := payload.Claims["email"]
	if !ok {
		logger.WarnContext(ctx, "Google identity token missing email claim", "subject", providerID)
		return LoginResponse{}, &pkgerrors.BadRequestError{Message: "Google identity token does not contain an email"}
	}
	email, ok := emailVal.(string)
	if !ok || email == "" {
		logger.WarnContext(ctx, "Google identity token has invalid email claim", "subject", providerID)
		return LoginResponse{}, &pkgerrors.BadRequestError{Message: "Google identity token does not contain an email"}
	}

	logger.DebugContext(ctx, "Valid Google token received", "provider_id", providerID, "email", email)

	u, err := s.getOrCreateUser(ctx, db.UsersModuleOauth2ProviderGOOGLE, providerID, email)
	if err != nil {
		logger.ErrorContext(ctx, "Failed to get or create user for Google login", "error", err, "email", email)
		return LoginResponse{}, err
	}

	jwtUser := security.JwtUser{
		ID:    u.ID,
		Email: u.Email,
	}

	accessToken, err := s.tokenProvider.GenerateAccessToken(jwtUser)
	if err != nil {
		logger.ErrorContext(ctx, "Failed to generate access token for Google login", "error", err, "user_id", u.ID.String())
		return LoginResponse{}, err
	}
	refreshToken, err := s.tokenProvider.GenerateRefreshToken(jwtUser)
	if err != nil {
		logger.ErrorContext(ctx, "Failed to generate refresh token for Google login", "error", err, "user_id", u.ID.String())
		return LoginResponse{}, err
	}

	logger.InfoContext(ctx, "Google login successful", "user_id", u.ID.String(), "email", u.Email)
	return LoginResponse{
		User: u,
		JwtTokens: JwtResponse{
			AccessToken:  accessToken,
			RefreshToken: refreshToken,
		},
	}, nil
}

func (s *Service) LoginReviewer(ctx context.Context, reviewerKey string) (LoginResponse, error) {
	logger.InfoContext(ctx, "Processing reviewer login")
	if !s.tokenProvider.ValidateReviewerKey(reviewerKey) {
		logger.WarnContext(ctx, "Invalid reviewer key provided")
		return LoginResponse{}, &pkgerrors.BadRequestError{Message: "Invalid reviewer key"}
	}

	u, err := s.getOrCreateUser(ctx, db.UsersModuleOauth2ProviderGOOGLE, "REVIEWER", "REVIEWER@TRENERIO.RU")
	if err != nil {
		logger.ErrorContext(ctx, "Failed to get or create user for reviewer login", "error", err)
		return LoginResponse{}, err
	}

	jwtUser := security.JwtUser{
		ID:    u.ID,
		Email: u.Email,
	}

	accessToken, err := s.tokenProvider.GenerateAccessToken(jwtUser)
	if err != nil {
		logger.ErrorContext(ctx, "Failed to generate access token for reviewer login", "error", err, "user_id", u.ID.String())
		return LoginResponse{}, err
	}
	refreshToken, err := s.tokenProvider.GenerateRefreshToken(jwtUser)
	if err != nil {
		logger.ErrorContext(ctx, "Failed to generate refresh token for reviewer login", "error", err, "user_id", u.ID.String())
		return LoginResponse{}, err
	}

	logger.InfoContext(ctx, "Reviewer login successful", "user_id", u.ID.String())
	return LoginResponse{
		User: u,
		JwtTokens: JwtResponse{
			AccessToken:  accessToken,
			RefreshToken: refreshToken,
		},
	}, nil
}

func (s *Service) RefreshTokens(ctx context.Context, refreshToken string) (JwtResponse, error) {
	logger.InfoContext(ctx, "Refreshing tokens")
	if !s.tokenProvider.IsTokenValid(refreshToken, "REFRESH") {
		logger.WarnContext(ctx, "Invalid or expired refresh token provided")
		return JwtResponse{}, &pkgerrors.BadRequestError{Message: "Invalid or expired refresh token"}
	}

	jwtUser, err := s.tokenProvider.ExtractUser(refreshToken)
	if err != nil {
		logger.WarnContext(ctx, "Failed to extract user from refresh token", "error", err)
		return JwtResponse{}, &pkgerrors.BadRequestError{Message: "Invalid or expired refresh token"}
	}

	logger.DebugContext(ctx, "Token user extracted", "user_id", jwtUser.ID.String(), "email", jwtUser.Email)

	exists, err := s.userExistsByID(ctx, jwtUser.ID)
	if err != nil {
		logger.ErrorContext(ctx, "Failed to check user existence during token refresh", "user_id", jwtUser.ID.String(), "error", err)
		return JwtResponse{}, err
	}
	if !exists {
		logger.WarnContext(ctx, "User not found during token refresh", "user_id", jwtUser.ID.String())
		return JwtResponse{}, &pkgerrors.BadRequestError{Message: "Invalid or expired refresh token"}
	}

	accessToken, err := s.tokenProvider.GenerateAccessToken(jwtUser)
	if err != nil {
		logger.ErrorContext(ctx, "Failed to generate access token during refresh", "user_id", jwtUser.ID.String(), "error", err)
		return JwtResponse{}, err
	}
	newRefreshToken, err := s.tokenProvider.GenerateRefreshToken(jwtUser)
	if err != nil {
		logger.ErrorContext(ctx, "Failed to generate refresh token during refresh", "user_id", jwtUser.ID.String(), "error", err)
		return JwtResponse{}, err
	}

	logger.InfoContext(ctx, "Tokens refreshed successfully", "user_id", jwtUser.ID.String())
	return JwtResponse{
		AccessToken:  accessToken,
		RefreshToken: newRefreshToken,
	}, nil
}
