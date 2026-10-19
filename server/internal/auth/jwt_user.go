package auth

import "github.com/google/uuid"

type JwtUser struct {
	ID    uuid.UUID
	Email string
}
