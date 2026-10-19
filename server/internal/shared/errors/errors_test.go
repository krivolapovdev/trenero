package errors

import (
	"encoding/json"
	"errors"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func init() {
	gin.SetMode(gin.TestMode)
}

func TestErrorTypes(t *testing.T) {
	cErr := &ConflictError{Code: "NAME_NOT_UNIQUE", Message: "Name is taken"}
	assert.Equal(t, "Name is taken", cErr.Error())

	bErr := &BadRequestError{Message: "Invalid input"}
	assert.Equal(t, "Invalid input", bErr.Error())

	id := uuid.New()
	ownerID := uuid.New()
	nErr := &NotFoundError{Entity: "Student", ID: id, OwnerID: ownerID}
	assert.Contains(t, nErr.Error(), "Student not found")
	assert.Contains(t, nErr.Error(), id.String())
}

func TestRespondFunctions(t *testing.T) {
	t.Run("RespondNotFound", func(t *testing.T) {
		w := httptest.NewRecorder()
		c, _ := gin.CreateTestContext(w)
		c.Request = httptest.NewRequest("GET", "/api/students/123", nil)

		RespondNotFound(c, "student not found")

		assert.Equal(t, http.StatusNotFound, w.Code)
		var pd ProblemDetail
		err := json.Unmarshal(w.Body.Bytes(), &pd)
		require.NoError(t, err)
		assert.Equal(t, "Not Found", pd.Title)
		assert.Equal(t, 404, pd.Status)
		assert.Equal(t, "student not found", pd.Detail)
		assert.Equal(t, "/api/students/123", pd.Instance)
	})

	t.Run("RespondConflict", func(t *testing.T) {
		w := httptest.NewRecorder()
		c, _ := gin.CreateTestContext(w)
		c.Request = httptest.NewRequest("POST", "/api/groups", nil)

		RespondConflict(c, "GROUP_NAME_NOT_UNIQUE", "group exists")

		assert.Equal(t, http.StatusConflict, w.Code)
		var pd ProblemDetail
		err := json.Unmarshal(w.Body.Bytes(), &pd)
		require.NoError(t, err)
		assert.Equal(t, "Conflict", pd.Title)
		assert.Equal(t, "GROUP_NAME_NOT_UNIQUE", pd.Code)
	})

	t.Run("RespondUnauthorized", func(t *testing.T) {
		w := httptest.NewRecorder()
		c, _ := gin.CreateTestContext(w)
		c.Request = httptest.NewRequest("GET", "/api/profile", nil)

		RespondUnauthorized(c, "")

		assert.Equal(t, http.StatusUnauthorized, w.Code)
		var pd ProblemDetail
		err := json.Unmarshal(w.Body.Bytes(), &pd)
		require.NoError(t, err)
		assert.Equal(t, "Unauthorized", pd.Title)
		assert.Equal(t, "Authentication failed or token is invalid", pd.Detail)
	})

	t.Run("RespondValidationFailed", func(t *testing.T) {
		w := httptest.NewRecorder()
		c, _ := gin.CreateTestContext(w)
		c.Request = httptest.NewRequest("POST", "/api/users", nil)

		errs := []map[string]interface{}{
			{"field": "email", "error": "email is required"},
		}
		RespondValidationFailed(c, errs)

		assert.Equal(t, http.StatusBadRequest, w.Code)
		var pd ProblemDetail
		err := json.Unmarshal(w.Body.Bytes(), &pd)
		require.NoError(t, err)
		assert.Equal(t, "Validation Failed", pd.Title)
		assert.Len(t, pd.Errors, 1)
	})

	t.Run("HandleError_InternalServerError", func(t *testing.T) {
		w := httptest.NewRecorder()
		c, _ := gin.CreateTestContext(w)
		c.Request = httptest.NewRequest("GET", "/api/data", nil)

		HandleError(c, errors.New("db connection failure"))

		assert.Equal(t, http.StatusInternalServerError, w.Code)
		var pd ProblemDetail
		err := json.Unmarshal(w.Body.Bytes(), &pd)
		require.NoError(t, err)
		assert.Equal(t, "Internal Server Error", pd.Title)
	})

	t.Run("HandleError_Nil", func(t *testing.T) {
		w := httptest.NewRecorder()
		c, _ := gin.CreateTestContext(w)
		HandleError(c, nil)
		assert.Equal(t, http.StatusOK, w.Code)
	})

	t.Run("HandleError_Conflict", func(t *testing.T) {
		w := httptest.NewRecorder()
		c, _ := gin.CreateTestContext(w)
		c.Request = httptest.NewRequest("POST", "/api/groups", nil)
		HandleError(c, NewConflict("CODE_EXISTS", "already exists"))
		assert.Equal(t, http.StatusConflict, w.Code)
	})

	t.Run("HandleError_NotFound", func(t *testing.T) {
		w := httptest.NewRecorder()
		c, _ := gin.CreateTestContext(w)
		c.Request = httptest.NewRequest("GET", "/api/students/123", nil)
		HandleError(c, NewNotFound("Student", uuid.New(), uuid.New()))
		assert.Equal(t, http.StatusNotFound, w.Code)
	})

	t.Run("HandleError_BadRequest", func(t *testing.T) {
		w := httptest.NewRecorder()
		c, _ := gin.CreateTestContext(w)
		c.Request = httptest.NewRequest("POST", "/api/test", nil)
		HandleError(c, NewBadRequest("bad data"))
		assert.Equal(t, http.StatusBadRequest, w.Code)
	})

	t.Run("HandleError_Unauthorized", func(t *testing.T) {
		w := httptest.NewRecorder()
		c, _ := gin.CreateTestContext(w)
		c.Request = httptest.NewRequest("GET", "/api/protected", nil)
		HandleError(c, NewUnauthorized("custom unauthorized"))
		assert.Equal(t, http.StatusUnauthorized, w.Code)
	})

	t.Run("HandleError_ValidationError", func(t *testing.T) {
		w := httptest.NewRecorder()
		c, _ := gin.CreateTestContext(w)
		c.Request = httptest.NewRequest("POST", "/api/validate", nil)
		vErr := NewValidationError([]map[string]any{{"field": "name", "error": "required"}})
		assert.Equal(t, "One or more fields in the request failed validation", vErr.Error())
		HandleError(c, vErr)
		assert.Equal(t, http.StatusBadRequest, w.Code)
	})
}

func TestErrorConstructors_EdgeCases(t *testing.T) {
	unauthDefault := NewUnauthorized("")
	assert.Equal(t, "Full authentication is required to access this resource", unauthDefault.Error())

	unauthCustom := NewUnauthorized("custom message")
	assert.Equal(t, "custom message", unauthCustom.Error())

	ctx, uri, path := getContextAndPath(nil)
	assert.NotNil(t, ctx)
	assert.Empty(t, uri)
	assert.Empty(t, path)
}
