package user

import (
	"net/http"

	"github.com/gin-gonic/gin"
	pkgerrors "github.com/krivolapovdev/trenerio/pkg/errors"
	"github.com/krivolapovdev/trenerio/pkg/httputil"
)

type Handler struct {
	service Service
}

func NewHandler(service Service) *Handler {
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
	jwtUser, ok := httputil.GetAuthUser(c)
	if !ok {
		return
	}

	if err := h.service.DeleteUser(c.Request.Context(), jwtUser); err != nil {
		pkgerrors.HandleError(c, err)
		return
	}

	c.Status(http.StatusNoContent)
}
