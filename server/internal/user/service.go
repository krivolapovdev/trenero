package user

import (
	"context"
	"database/sql"
	"errors"
	"strings"

	"github.com/google/uuid"
	"github.com/krivolapovdev/trenerio/internal/db"
	pkgerrors "github.com/krivolapovdev/trenerio/pkg/errors"
	"github.com/krivolapovdev/trenerio/pkg/logger"
	"github.com/krivolapovdev/trenerio/pkg/security"
)

type Service struct {
	db *db.Queries
}

func NewService(queries *db.Queries) *Service {
	return &Service{
		db: queries,
	}
}

func (s *Service) GetOrCreateUserFromOAuth2(ctx context.Context, provider db.UsersModuleOauth2Provider, providerID, email string) (UserResponse, error) {
	logger.InfoContext(ctx, "Get or create user from OAuth2", "provider", string(provider), "email", email)
	u, err := s.db.GetUserByProviderAndProviderID(ctx, db.GetUserByProviderAndProviderIDParams{
		Provider:   provider,
		ProviderID: providerID,
	})
	if err == nil {
		logger.DebugContext(ctx, "Existing OAuth2 user found", "user_id", u.ID.String(), "provider", string(provider))
		return UserResponse{
			ID:    u.ID,
			Email: u.Email,
		}, nil
	}
	if !errors.Is(err, sql.ErrNoRows) {
		logger.ErrorContext(ctx, "Failed to query OAuth2 user", "error", err, "provider", string(provider))
		return UserResponse{}, err
	}

	normalizedEmail := strings.ToUpper(strings.TrimSpace(email))
	logger.InfoContext(ctx, "Creating new user", "provider", string(provider), "email", normalizedEmail)
	created, err := s.db.CreateUser(ctx, db.CreateUserParams{
		Provider:   provider,
		ProviderID: providerID,
		Email:      normalizedEmail,
	})
	if err != nil {
		logger.ErrorContext(ctx, "Failed to create user in database", "error", err, "provider", string(provider), "email", normalizedEmail)
		return UserResponse{}, err
	}

	logger.InfoContext(ctx, "User created successfully", "user_id", created.ID.String(), "email", created.Email)
	return UserResponse{
		ID:    created.ID,
		Email: created.Email,
	}, nil
}

func (s *Service) ExistsByID(ctx context.Context, id uuid.UUID) (bool, error) {
	logger.DebugContext(ctx, "Checking whether user exists", "id", id.String())
	exists, err := s.db.ExistsUserByID(ctx, id)
	if err != nil {
		logger.ErrorContext(ctx, "Failed to check if user exists", "id", id.String(), "error", err)
	}
	return exists, err
}

func (s *Service) DeleteUser(ctx context.Context, jwtUser security.JwtUser) error {
	logger.InfoContext(ctx, "Deleting user", "user_id", jwtUser.ID.String())
	exists, err := s.db.ExistsUserByID(ctx, jwtUser.ID)
	if err != nil {
		logger.ErrorContext(ctx, "Failed to check user existence for deletion", "user_id", jwtUser.ID.String(), "error", err)
		return err
	}
	if !exists {
		logger.WarnContext(ctx, "User to delete not found", "user_id", jwtUser.ID.String())
		return &pkgerrors.NotFoundError{
			Entity:  "OAuth2User",
			ID:      jwtUser.ID,
			OwnerID: jwtUser.ID,
		}
	}
	if err := s.db.DeleteUserByID(ctx, jwtUser.ID); err != nil {
		logger.ErrorContext(ctx, "Failed to delete user from database", "user_id", jwtUser.ID.String(), "error", err)
		return err
	}
	logger.InfoContext(ctx, "User deleted successfully", "user_id", jwtUser.ID.String())
	return nil
}
