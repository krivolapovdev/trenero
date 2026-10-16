package auth

import (
	"net/http"

	"github.com/gin-gonic/gin"
	pkgerrors "github.com/krivolapovdev/trenerio/pkg/errors"
	"github.com/krivolapovdev/trenerio/pkg/httputil"
	"github.com/krivolapovdev/trenerio/pkg/types"
)

type Handler struct {
	service Service
}

func NewHandler(service Service) *Handler {
	return &Handler{
		service: service,
	}
}

// RegisterRoutes registers the authentication routes onto the given router group.
func (h *Handler) RegisterRoutes(rg *gin.RouterGroup) {
	jwtGroup := rg.Group("/jwt")
	{
		jwtGroup.POST("/refresh", h.RefreshTokens)
	}

	oauth2Group := rg.Group("/oauth2")
	{
		oauth2Group.POST("/google", h.GoogleLogin)
	}

	reviewerGroup := rg.Group("/reviewer")
	{
		reviewerGroup.POST("/login", h.ReviewerLogin)
	}
}

// GoogleLogin
// @ID           googleLogin
// @Tags         o-auth-2-controller
// @Param        body  body      models.OAuth2LoginRequest  true  "Google OAuth2 login request"
// @Success      200   {object}  models.LoginResponse
// @Router       /api/v1/oauth2/google [post]
func (h *Handler) GoogleLogin(c *gin.Context) {
	var req OAuth2LoginRequest
	if !httputil.BindJSON(c, &req) {
		return
	}

	loginResponse, err := h.service.LoginGoogle(c.Request.Context(), req.Token)
	if err != nil {
		pkgerrors.HandleError(c, err)
		return
	}

	c.JSON(http.StatusOK, loginResponse)
}

// RefreshTokens
// @ID           refreshTokens
// @Tags         jwt-controller
// @Param        body  body      models.RefreshTokenRequest  true  "Refresh token request"
// @Success      200   {object}  models.JwtResponse
// @Router       /api/v1/jwt/refresh [post]
func (h *Handler) RefreshTokens(c *gin.Context) {
	var req RefreshTokenRequest
	if !httputil.BindJSON(c, &req) {
		return
	}

	jwtTokens, err := h.service.RefreshTokens(c.Request.Context(), req.RefreshToken)
	if err != nil {
		pkgerrors.HandleError(c, err)
		return
	}

	c.JSON(http.StatusOK, jwtTokens)
}

// ReviewerLogin
// @ID           login
// @Tags         reviewer-auth-controller
// @Param        X-Reviewer-Key  header    string  true  "Reviewer secret key"
// @Success      200             {object}  models.LoginResponse
// @Router       /api/v1/reviewer/login [post]
func (h *Handler) ReviewerLogin(c *gin.Context) {
	reviewerKey := c.GetHeader(types.HeaderXReviewerKey)
	if reviewerKey == "" {
		pkgerrors.RespondUnauthorized(c, "Authentication failed or token is invalid")
		return
	}

	loginResponse, err := h.service.LoginReviewer(c.Request.Context(), reviewerKey)
	if err != nil {
		pkgerrors.HandleError(c, err)
		return
	}

	c.JSON(http.StatusOK, loginResponse)
}
