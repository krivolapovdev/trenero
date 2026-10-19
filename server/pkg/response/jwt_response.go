package response

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
