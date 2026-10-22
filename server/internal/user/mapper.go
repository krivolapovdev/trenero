package user

import (
	"github.com/krivolapovdev/trenerio/internal/db"
	"github.com/krivolapovdev/trenerio/internal/shared/response"
)

func toUserResponse(u db.UsersModuleOauth2User) response.UserResponse {
	return response.UserResponse{
		ID:    u.ID,
		Email: u.Email,
	}
}
