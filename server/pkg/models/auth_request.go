package models

// @name OAuth2LoginRequest
type OAuth2LoginRequest struct {
	Token string `json:"token" binding:"required" validate:"required"`
}

// @name RefreshTokenRequest
type RefreshTokenRequest struct {
	RefreshToken string `json:"refreshToken" binding:"required" validate:"required"`
}
