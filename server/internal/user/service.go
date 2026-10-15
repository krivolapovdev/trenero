package user

import (
	"context"
	"database/sql"
	"errors"
	"strings"

	"github.com/google/uuid"
	"github.com/krivolapovdev/trenerio/internal/db"
	pkgerrors "github.com/krivolapovdev/trenerio/pkg/errors"
	"github.com/krivolapovdev/trenerio/pkg/security"
)

type UserService struct {
	db *db.Queries
}

func NewUserService(queries *db.Queries) *UserService {
	return &UserService{
		db: queries,
	}
}

func (s *UserService) GetOrCreateUserFromOAuth2(ctx context.Context, provider db.UsersModuleOauth2Provider, providerID, email string) (UserResponse, error) {
	u, err := s.db.GetUserByProviderAndProviderID(ctx, db.GetUserByProviderAndProviderIDParams{
		Provider:   provider,
		ProviderID: providerID,
	})
	if err == nil {
		return UserResponse{
			ID:    u.ID,
			Email: u.Email,
		}, nil
	}
	if !errors.Is(err, sql.ErrNoRows) {
		return UserResponse{}, err
	}

	normalizedEmail := strings.ToUpper(strings.TrimSpace(email))
	created, err := s.db.CreateUser(ctx, db.CreateUserParams{
		Provider:   provider,
		ProviderID: providerID,
		Email:      normalizedEmail,
	})
	if err != nil {
		return UserResponse{}, err
	}

	return UserResponse{
		ID:    created.ID,
		Email: created.Email,
	}, nil
}

func (s *UserService) ExistsByID(ctx context.Context, id uuid.UUID) (bool, error) {
	return s.db.ExistsUserByID(ctx, id)
}

func (s *UserService) DeleteUser(ctx context.Context, jwtUser security.JwtUser) error {
	exists, err := s.db.ExistsUserByID(ctx, jwtUser.ID)
	if err != nil {
		return err
	}
	if !exists {
		return &pkgerrors.NotFoundError{
			Entity:  "OAuth2User",
			ID:      jwtUser.ID,
			OwnerID: jwtUser.ID,
		}
	}
	return s.db.DeleteUserByID(ctx, jwtUser.ID)
}
