package user

import (
	"net/http"

	"github.com/gin-gonic/gin"
	pkgerrors "github.com/krivolapovdev/trenerio/pkg/errors"
	"github.com/krivolapovdev/trenerio/pkg/security"
	"github.com/krivolapovdev/trenerio/pkg/types"
)

type Handler struct {
	service *Service
}

func NewHandler(service *Service) *Handler {
	return &Handler{
		service: service,
	}
}

// DeleteMyAccount
// @ID           deleteMyAccount
// @Tags         user-controller
// @Security     BearerAuth
// @Success      204  "No Content"
// @Router       /api/v1/users/me [delete]
func (h *Handler) DeleteMyAccount(c *gin.Context) {
	val, exists := c.Get(types.ContextKeyJWTUser)
	if !exists {
		pkgerrors.RespondUnauthorized(c, "")
		c.Abort()
		return
	}
	jwtUser, ok := val.(security.JwtUser)
	if !ok {
		pkgerrors.RespondUnauthorized(c, "")
		c.Abort()
		return
	}

	if err := h.service.DeleteUser(c.Request.Context(), jwtUser); err != nil {
		pkgerrors.HandleError(c, err)
		return
	}

	c.Status(http.StatusNoContent)
}
