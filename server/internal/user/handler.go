package user

import (
	"context"
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/krivolapovdev/trenerio/internal/auth"
	pkgerrors "github.com/krivolapovdev/trenerio/internal/shared/errors"
)

type userService interface {
	DeleteUser(ctx context.Context, jwtUser auth.JwtUser) error
}

type Handler struct {
	service userService
}

func NewHandler(service userService) *Handler {
	return &Handler{
		service: service,
	}
}

// RegisterRoutes registers the user routes onto the given router group.
func (h *Handler) RegisterRoutes(rg *gin.RouterGroup) {
	users := rg.Group("/users")
	{
		users.DELETE("/me", h.DeleteMyAccount)
	}
}

// DeleteMyAccount
// @ID           deleteMyAccount
// @Tags         user-controller
// @Security     BearerAuth
// @Success      204  "No Content"
// @Router       /api/v1/users/me [delete]
func (h *Handler) DeleteMyAccount(c *gin.Context) {
	jwtUser, ok := auth.GetUserFromContext(c)
	if !ok {
		return
	}

	if err := h.service.DeleteUser(c.Request.Context(), jwtUser); err != nil {
		pkgerrors.HandleError(c, err)
		return
	}

	c.Status(http.StatusNoContent)
}
