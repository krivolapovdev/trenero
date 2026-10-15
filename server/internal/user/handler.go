package user

import (
	"net/http"

	"github.com/gin-gonic/gin"
	pkgerrors "github.com/krivolapovdev/trenerio/pkg/errors"
	"github.com/krivolapovdev/trenerio/pkg/security"
)

type UserHandler struct {
	service *UserService
}

func NewUserHandler(service *UserService) *UserHandler {
	return &UserHandler{
		service: service,
	}
}

func (h *UserHandler) DeleteMyAccount(c *gin.Context) {
	val, exists := c.Get("jwtUser")
	if !exists {
		pkgerrors.RespondUnauthorized(c, "")
		return
	}
	jwtUser, ok := val.(security.JwtUser)
	if !ok {
		pkgerrors.RespondUnauthorized(c, "")
		return
	}

	err := h.service.DeleteUser(c.Request.Context(), jwtUser)
	if err != nil {
		pkgerrors.HandleError(c, err)
		return
	}

	c.Status(http.StatusNoContent)
}
