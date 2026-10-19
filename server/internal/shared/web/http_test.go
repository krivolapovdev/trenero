package web

import (
	"bytes"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func init() {
	gin.SetMode(gin.TestMode)
}

func TestParseUUIDParam(t *testing.T) {
	t.Run("ValidUUID", func(t *testing.T) {
		expectedID := uuid.New()
		w := httptest.NewRecorder()
		c, _ := gin.CreateTestContext(w)
		c.Params = gin.Params{{Key: "id", Value: expectedID.String()}}

		id, ok := ParseUUIDParam(c, "id")
		assert.True(t, ok)
		assert.Equal(t, expectedID, id)
	})

	t.Run("InvalidUUID", func(t *testing.T) {
		w := httptest.NewRecorder()
		c, _ := gin.CreateTestContext(w)
		c.Request = httptest.NewRequest(http.MethodGet, "/test", nil)
		c.Params = gin.Params{{Key: "id", Value: "invalid-uuid"}}

		id, ok := ParseUUIDParam(c, "id")
		assert.False(t, ok)
		assert.Equal(t, uuid.Nil, id)
		assert.Equal(t, http.StatusBadRequest, w.Code)
	})
}

func TestBindJSON(t *testing.T) {
	type SamplePayload struct {
		Name string `json:"name" binding:"required"`
	}

	t.Run("ValidJSON", func(t *testing.T) {
		w := httptest.NewRecorder()
		c, _ := gin.CreateTestContext(w)
		c.Request = httptest.NewRequest(http.MethodPost, "/", bytes.NewBufferString(`{"name":"Alex"}`))
		c.Request.Header.Set("Content-Type", "application/json")

		var payload SamplePayload
		ok := BindJSON(c, &payload)
		assert.True(t, ok)
		assert.Equal(t, "Alex", payload.Name)
	})

	t.Run("InvalidJSON", func(t *testing.T) {
		w := httptest.NewRecorder()
		c, _ := gin.CreateTestContext(w)
		c.Request = httptest.NewRequest(http.MethodPost, "/", bytes.NewBufferString(`{invalid-json`))
		c.Request.Header.Set("Content-Type", "application/json")

		var payload SamplePayload
		ok := BindJSON(c, &payload)
		assert.False(t, ok)
		assert.Equal(t, http.StatusBadRequest, w.Code)
	})
}

func TestParsePagination(t *testing.T) {
	t.Run("DefaultValues", func(t *testing.T) {
		w := httptest.NewRecorder()
		c, _ := gin.CreateTestContext(w)
		c.Request = httptest.NewRequest(http.MethodGet, "/items", nil)

		page, size := ParsePagination(c, 1, 20)
		assert.Equal(t, 1, page)
		assert.Equal(t, 20, size)
	})

	t.Run("ExplicitValues", func(t *testing.T) {
		w := httptest.NewRecorder()
		c, _ := gin.CreateTestContext(w)
		c.Request = httptest.NewRequest(http.MethodGet, "/items?page=3&size=50", nil)

		page, size := ParsePagination(c, 1, 20)
		assert.Equal(t, 3, page)
		assert.Equal(t, 50, size)
	})

	t.Run("NegativeOrZeroValues", func(t *testing.T) {
		w := httptest.NewRecorder()
		c, _ := gin.CreateTestContext(w)
		c.Request = httptest.NewRequest(http.MethodGet, "/items?page=-1&size=0", nil)

		page, size := ParsePagination(c, 1, 20)
		assert.Equal(t, 1, page)
		assert.Equal(t, 20, size)
	})

	t.Run("CapMaxPageSize", func(t *testing.T) {
		w := httptest.NewRecorder()
		c, _ := gin.CreateTestContext(w)
		c.Request = httptest.NewRequest(http.MethodGet, "/items?page=1&size=5000", nil)

		page, size := ParsePagination(c, 1, 20)
		assert.Equal(t, 1, page)
		assert.Equal(t, 100, size)
	})
}

func TestParseOptionalRFC3339(t *testing.T) {
	t.Run("EmptyQueryParam", func(t *testing.T) {
		w := httptest.NewRecorder()
		c, _ := gin.CreateTestContext(w)
		c.Request = httptest.NewRequest(http.MethodGet, "/items", nil)

		res := ParseOptionalRFC3339(c, "from")
		assert.Nil(t, res)
	})

	t.Run("ValidRFC3339", func(t *testing.T) {
		w := httptest.NewRecorder()
		c, _ := gin.CreateTestContext(w)
		targetTime := time.Date(2026, 10, 17, 12, 0, 0, 0, time.UTC)
		c.Request = httptest.NewRequest(http.MethodGet, "/items?from="+targetTime.Format(time.RFC3339), nil)

		res := ParseOptionalRFC3339(c, "from")
		require.NotNil(t, res)
		assert.True(t, res.Equal(targetTime))
	})

	t.Run("InvalidRFC3339", func(t *testing.T) {
		w := httptest.NewRecorder()
		c, _ := gin.CreateTestContext(w)
		c.Request = httptest.NewRequest(http.MethodGet, "/items?from=not-a-date", nil)

		res := ParseOptionalRFC3339(c, "from")
		assert.Nil(t, res)
	})
}
