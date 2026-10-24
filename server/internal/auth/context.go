package auth

import (
	"github.com/gin-gonic/gin"
	pkgerrors "github.com/krivolapovdev/trenerio/internal/shared/errors"
)

const (
	ContextKeyJWTUser = "jwtUser"
)

func GetUserFromContext(c *gin.Context) (JwtUser, bool) {
	val, exists := c.Get(ContextKeyJWTUser)
	if !exists {
		pkgerrors.RespondUnauthorized(c, "")
		c.Abort()
		return JwtUser{}, false
	}

	u, ok := val.(JwtUser)
	if !ok {
		pkgerrors.RespondUnauthorized(c, "")
		c.Abort()
		return JwtUser{}, false
	}

	return u, true
}
