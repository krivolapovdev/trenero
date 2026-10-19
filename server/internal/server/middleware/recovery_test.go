package middleware

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gin-gonic/gin"
	pkgerrors "github.com/krivolapovdev/trenerio/internal/shared/errors"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestRecoveryMiddleware(t *testing.T) {
	gin.SetMode(gin.TestMode)
	r := gin.New()
	r.Use(RecoveryMiddleware())
	r.GET("/panic", func(c *gin.Context) {
		panic("something went completely wrong")
	})

	w := httptest.NewRecorder()
	req := httptest.NewRequest(http.MethodGet, "/panic", nil)
	r.ServeHTTP(w, req)

	assert.Equal(t, http.StatusInternalServerError, w.Code)
	var pd pkgerrors.ProblemDetail
	err := json.Unmarshal(w.Body.Bytes(), &pd)
	require.NoError(t, err)
	assert.Equal(t, "Internal Server Error", pd.Title)
	assert.Contains(t, pd.Detail, "something went completely wrong")
}
