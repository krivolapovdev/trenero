package utils

import (
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/stretchr/testify/assert"
)

func TestParseRequiredRFC3339(t *testing.T) {
	gin.SetMode(gin.TestMode)

	t.Run("MissingParam_ReturnsFalse", func(t *testing.T) {
		w := httptest.NewRecorder()
		c, _ := gin.CreateTestContext(w)
		c.Request = httptest.NewRequest(http.MethodGet, "/test", nil)

		_, ok := ParseRequiredRFC3339(c, "from")
		assert.False(t, ok)
		assert.Equal(t, http.StatusBadRequest, w.Code)
		assert.True(t, c.IsAborted())
	})

	t.Run("InvalidFormat_ReturnsFalse", func(t *testing.T) {
		w := httptest.NewRecorder()
		c, _ := gin.CreateTestContext(w)
		c.Request = httptest.NewRequest(http.MethodGet, "/test?from=invalid-date", nil)

		_, ok := ParseRequiredRFC3339(c, "from")
		assert.False(t, ok)
		assert.Equal(t, http.StatusBadRequest, w.Code)
		assert.True(t, c.IsAborted())
	})

	t.Run("ValidFormat_ReturnsTime", func(t *testing.T) {
		expected := time.Date(2026, 5, 10, 15, 4, 5, 0, time.UTC)
		w := httptest.NewRecorder()
		c, _ := gin.CreateTestContext(w)
		c.Request = httptest.NewRequest(http.MethodGet, "/test?from="+expected.Format(time.RFC3339), nil)

		parsed, ok := ParseRequiredRFC3339(c, "from")
		assert.True(t, ok)
		assert.True(t, expected.Equal(parsed))
		assert.False(t, c.IsAborted())
	})
}

func TestParseRequiredRFC3339Range(t *testing.T) {
	gin.SetMode(gin.TestMode)

	t.Run("MissingStart_ReturnsFalse", func(t *testing.T) {
		w := httptest.NewRecorder()
		c, _ := gin.CreateTestContext(w)
		c.Request = httptest.NewRequest(http.MethodGet, "/test?to=2026-05-10T00:00:00Z", nil)

		_, _, ok := ParseRequiredRFC3339Range(c, "from", "to", "from and to query parameters are required")
		assert.False(t, ok)
		assert.Equal(t, http.StatusBadRequest, w.Code)
		assert.True(t, c.IsAborted())
	})

	t.Run("InvalidEndFormat_ReturnsFalse", func(t *testing.T) {
		w := httptest.NewRecorder()
		c, _ := gin.CreateTestContext(w)
		c.Request = httptest.NewRequest(http.MethodGet, "/test?from=2026-05-10T00:00:00Z&to=bad", nil)

		_, _, ok := ParseRequiredRFC3339Range(c, "from", "to", "")
		assert.False(t, ok)
		assert.Equal(t, http.StatusBadRequest, w.Code)
		assert.True(t, c.IsAborted())
	})

	t.Run("ValidRange_ReturnsBothTimes", func(t *testing.T) {
		start := time.Date(2026, 1, 1, 0, 0, 0, 0, time.UTC)
		end := time.Date(2026, 1, 31, 0, 0, 0, 0, time.UTC)

		w := httptest.NewRecorder()
		c, _ := gin.CreateTestContext(w)
		c.Request = httptest.NewRequest(http.MethodGet, "/test?from="+start.Format(time.RFC3339)+"&to="+end.Format(time.RFC3339), nil)

		resStart, resEnd, ok := ParseRequiredRFC3339Range(c, "from", "to", "")
		assert.True(t, ok)
		assert.True(t, start.Equal(resStart))
		assert.True(t, end.Equal(resEnd))
		assert.False(t, c.IsAborted())
	})
}
