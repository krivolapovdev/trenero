package auth

import (
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/stretchr/testify/assert"
)

func TestGetUserFromContext(t *testing.T) {
	gin.SetMode(gin.TestMode)

	t.Run("UserExistsInContext", func(t *testing.T) {
		w := httptest.NewRecorder()
		c, _ := gin.CreateTestContext(w)

		expectedUser := JwtUser{
			ID:    uuid.New(),
			Email: "test@example.com",
		}
		c.Set(ContextKeyJWTUser, expectedUser)

		user, ok := GetUserFromContext(c)
		assert.True(t, ok)
		assert.Equal(t, expectedUser, user)
		assert.False(t, c.IsAborted())
	})

	t.Run("UserDoesNotExistInContext", func(t *testing.T) {
		w := httptest.NewRecorder()
		c, _ := gin.CreateTestContext(w)

		user, ok := GetUserFromContext(c)
		assert.False(t, ok)
		assert.Equal(t, JwtUser{}, user)
		assert.True(t, c.IsAborted())
		assert.Equal(t, http.StatusUnauthorized, w.Code)
	})

	t.Run("InvalidTypeInContext", func(t *testing.T) {
		w := httptest.NewRecorder()
		c, _ := gin.CreateTestContext(w)

		c.Set(ContextKeyJWTUser, "not-a-jwt-user")

		user, ok := GetUserFromContext(c)
		assert.False(t, ok)
		assert.Equal(t, JwtUser{}, user)
		assert.True(t, c.IsAborted())
		assert.Equal(t, http.StatusUnauthorized, w.Code)
	})
}
