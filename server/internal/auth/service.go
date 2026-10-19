package auth

import (
	"context"
	"github.com/krivolapovdev/trenerio/pkg/response"

	"github.com/google/uuid"
	"github.com/krivolapovdev/trenerio/internal/db"
	pkgerrors "github.com/krivolapovdev/trenerio/pkg/errors"
	"github.com/krivolapovdev/trenerio/pkg/logger"
	"github.com/krivolapovdev/trenerio/pkg/security"
	"github.com/krivolapovdev/trenerio/pkg/types"
	"google.golang.org/api/idtoken"
)

const (
	ReviewerProviderID = "REVIEWER"
	ReviewerEmail      = "REVIEWER@TRENERIO.RU"
)

type GetOrCreateUserFunc func(ctx context.Context, provider db.UsersModuleOauth2Provider, providerID, email string) (response.UserResponse, error)
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

func (s *Service) LoginGoogle(ctx context.Context, token string) (response.LoginResponse, error) {
	logger.InfoContext(ctx, "Processing Google login")
	payload, err := idtoken.Validate(ctx, token, s.googleClientID)
	if err != nil {
		logger.WarnContext(ctx, "Failed to validate Google identity token", "error", err)
		return response.LoginResponse{}, pkgerrors.NewBadRequest("Invalid or expired Google identity token")
	}

	providerID := payload.Subject
	if providerID == "" {
		logger.WarnContext(ctx, "Google identity token does not contain a subject")
		return response.LoginResponse{}, pkgerrors.NewBadRequest("Google identity token does not contain a subject")
	}

	emailVal, ok := payload.Claims["email"]
	if !ok {
		logger.WarnContext(ctx, "Google identity token missing email claim", "subject", providerID)
		return response.LoginResponse{}, pkgerrors.NewBadRequest("Google identity token does not contain an email")
	}
	email, ok := emailVal.(string)
	if !ok || email == "" {
		logger.WarnContext(ctx, "Google identity token has invalid email claim", "subject", providerID)
		return response.LoginResponse{}, pkgerrors.NewBadRequest("Google identity token does not contain an email")
	}

	logger.DebugContext(ctx, "Valid Google token received", "provider_id", providerID, "email", email)

	u, err := s.getOrCreateUser(ctx, db.UsersModuleOauth2ProviderGOOGLE, providerID, email)
	if err != nil {
		logger.ErrorContext(ctx, "Failed to get or create user for Google login", "error", err, "email", email)
		return response.LoginResponse{}, err
	}

	resp, err := generateLoginResponse(ctx, s.tokenProvider, u, "Google")
	if err != nil {
		return response.LoginResponse{}, err
	}
	logger.InfoContext(ctx, "Google login successful", "user_id", u.ID.String(), "email", u.Email)
	return resp, nil
}

func (s *Service) LoginReviewer(ctx context.Context, reviewerKey string) (response.LoginResponse, error) {
	logger.InfoContext(ctx, "Processing reviewer login")
	if !s.tokenProvider.ValidateReviewerKey(reviewerKey) {
		logger.WarnContext(ctx, "Invalid reviewer key provided")
		return response.LoginResponse{}, pkgerrors.NewBadRequest("Invalid reviewer key")
	}

	u, err := s.getOrCreateUser(ctx, db.UsersModuleOauth2ProviderGOOGLE, ReviewerProviderID, ReviewerEmail)
	if err != nil {
		logger.ErrorContext(ctx, "Failed to get or create user for reviewer login", "error", err)
		return response.LoginResponse{}, err
	}

	resp, err := generateLoginResponse(ctx, s.tokenProvider, u, "reviewer")
	if err != nil {
		return response.LoginResponse{}, err
	}
	logger.InfoContext(ctx, "Reviewer login successful", "user_id", u.ID.String())
	return resp, nil
}

func (s *Service) RefreshTokens(ctx context.Context, refreshToken string) (response.JwtResponse, error) {
	logger.InfoContext(ctx, "Refreshing tokens")
	if !s.tokenProvider.IsTokenValid(refreshToken, types.TokenTypeRefresh) {
		logger.WarnContext(ctx, "Invalid or expired refresh token provided")
		return response.JwtResponse{}, pkgerrors.NewBadRequest("Invalid or expired refresh token")
	}

	jwtUser, err := s.tokenProvider.ExtractUser(refreshToken)
	if err != nil {
		logger.WarnContext(ctx, "Failed to extract user from refresh token", "error", err)
		return response.JwtResponse{}, pkgerrors.NewBadRequest("Invalid or expired refresh token")
	}

	logger.DebugContext(ctx, "Token user extracted", "user_id", jwtUser.ID.String(), "email", jwtUser.Email)

	exists, err := s.userExistsByID(ctx, jwtUser.ID)
	if err != nil {
		logger.ErrorContext(ctx, "Failed to check user existence during token refresh", "user_id", jwtUser.ID.String(), "error", err)
		return response.JwtResponse{}, err
	}
	if !exists {
		logger.WarnContext(ctx, "User not found during token refresh", "user_id", jwtUser.ID.String())
		return response.JwtResponse{}, pkgerrors.NewBadRequest("Invalid or expired refresh token")
	}

	accessToken, err := s.tokenProvider.GenerateAccessToken(jwtUser)
	if err != nil {
		logger.ErrorContext(ctx, "Failed to generate access token during refresh", "user_id", jwtUser.ID.String(), "error", err)
		return response.JwtResponse{}, err
	}
	newRefreshToken, err := s.tokenProvider.GenerateRefreshToken(jwtUser)
	if err != nil {
		logger.ErrorContext(ctx, "Failed to generate refresh token during refresh", "user_id", jwtUser.ID.String(), "error", err)
		return response.JwtResponse{}, err
	}

	logger.InfoContext(ctx, "Tokens refreshed successfully", "user_id", jwtUser.ID.String())
	return response.JwtResponse{
		AccessToken:  accessToken,
		RefreshToken: newRefreshToken,
	}, nil
}
