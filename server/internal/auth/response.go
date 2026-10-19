package auth

import "github.com/google/uuid"

// @name UserResponse
type UserResponse struct {
	ID    uuid.UUID `json:"id" binding:"required" format:"uuid"`
	Email string    `json:"email" binding:"required"`
}

// @name JwtResponse
type JwtResponse struct {
	AccessToken  string `json:"accessToken" binding:"required"`
	RefreshToken string `json:"refreshToken" binding:"required"`
}

// @name LoginResponse
type LoginResponse struct {
	User      UserResponse `json:"user" binding:"required"`
	JwtTokens JwtResponse  `json:"jwtTokens" binding:"required"`
}
