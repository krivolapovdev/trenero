package auth

import (
	"net/http"

	"github.com/gin-gonic/gin"
	pkgerrors "github.com/krivolapovdev/trenerio/pkg/errors"
)

type AuthHandler struct {
	service *AuthService
}

func NewAuthHandler(service *AuthService) *AuthHandler {
	return &AuthHandler{
		service: service,
	}
}

func (h *AuthHandler) GoogleLogin(c *gin.Context) {
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

func (h *AuthHandler) RefreshTokens(c *gin.Context) {
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

func (h *AuthHandler) ReviewerLogin(c *gin.Context) {
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
