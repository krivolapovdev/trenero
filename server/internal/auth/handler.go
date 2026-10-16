package auth

import (
	"net/http"

	"github.com/gin-gonic/gin"
	pkgerrors "github.com/krivolapovdev/trenerio/pkg/errors"
)

type Handler struct {
	service *Service
}

func NewHandler(service *Service) *Handler {
	return &Handler{
		service: service,
	}
}

// GoogleLogin
// @ID           googleLogin
// @Tags         o-auth-2-controller
// @Param        request  body      models.OAuth2LoginRequest  true  "Google OAuth2 login request"
// @Success      200      {object}  models.LoginResponse
// @Router       /api/v1/oauth2/google [post]
func (h *Handler) GoogleLogin(c *gin.Context) {
	var req OAuth2LoginRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		pkgerrors.RespondBadRequest(c, "Request body is missing or has invalid format")
		return
	}

	resp, err := h.service.LoginGoogle(c.Request.Context(), req.Token)
	if err != nil {
		pkgerrors.HandleError(c, err)
		return
	}

	c.JSON(http.StatusOK, resp)
}

// RefreshTokens
// @ID           refreshTokens
// @Tags         jwt-controller
// @Param        request  body      models.RefreshTokenRequest  true  "Refresh token request"
// @Success      200      {object}  models.JwtResponse
// @Router       /api/v1/jwt/refresh [post]
func (h *Handler) RefreshTokens(c *gin.Context) {
	var req RefreshTokenRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		pkgerrors.RespondBadRequest(c, "Request body is missing or has invalid format")
		return
	}

	resp, err := h.service.RefreshTokens(c.Request.Context(), req.RefreshToken)
	if err != nil {
		pkgerrors.HandleError(c, err)
		return
	}

	c.JSON(http.StatusOK, resp)
}

// ReviewerLogin
// @ID           reviewerLogin
// @Tags         reviewer-auth-controller
// @Param        X-Reviewer-Key  header    string  true  "Reviewer secret key"
// @Success      200             {object}  models.LoginResponse
// @Router       /api/v1/reviewer/login [post]
func (h *Handler) ReviewerLogin(c *gin.Context) {
	reviewerKey := c.GetHeader("X-Reviewer-Key")
	if reviewerKey == "" {
		pkgerrors.RespondUnauthorized(c, "Authentication failed or token is invalid")
		return
	}

	resp, err := h.service.LoginReviewer(c.Request.Context(), reviewerKey)
	if err != nil {
		pkgerrors.HandleError(c, err)
		return
	}

	c.JSON(http.StatusOK, resp)
}
