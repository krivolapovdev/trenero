package user

import (
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/krivolapovdev/trenerio/internal/db"
	"github.com/stretchr/testify/assert"
)

func TestToUserResponse(t *testing.T) {
	userID := uuid.New()
	u := db.UsersModuleOauth2User{
		ID:         userID,
		Provider:   db.UsersModuleOauth2ProviderGOOGLE,
		ProviderID: "google-12345",
		Email:      "TEST@EXAMPLE.COM",
		CreatedAt:  time.Now(),
	}

	resp := toUserResponse(u)
	assert.Equal(t, userID, resp.ID)
	assert.Equal(t, "TEST@EXAMPLE.COM", resp.Email)
}
