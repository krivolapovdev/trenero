package models

// @name JwtResponse
type JwtResponse struct {
	AccessToken  string `json:"accessToken"`
	RefreshToken string `json:"refreshToken"`
}

// @name LoginResponse
type LoginResponse struct {
	User      UserResponse `json:"user"`
	JwtTokens JwtResponse  `json:"jwtTokens"`
}
