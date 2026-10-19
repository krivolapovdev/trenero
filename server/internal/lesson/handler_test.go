package lesson

import (
	"bytes"
	"context"
	"encoding/json"
	"github.com/krivolapovdev/trenerio/pkg/request"
	"github.com/krivolapovdev/trenerio/pkg/response"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	pkgerrors "github.com/krivolapovdev/trenerio/pkg/errors"
	"github.com/krivolapovdev/trenerio/pkg/security"
	"github.com/krivolapovdev/trenerio/pkg/testutil"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

type mockLessonService struct {
	getLessonByIDFn        func(ctx context.Context, lessonID, ownerID uuid.UUID) (response.LessonResponse, error)
	getLessonDetailsByIDFn func(ctx context.Context, lessonID, ownerID uuid.UUID) (response.LessonDetailsResponse, error)
	createLessonFn         func(ctx context.Context, req request.CreateLessonRequest, ownerID uuid.UUID) (response.LessonResponse, error)
	updateLessonFn         func(ctx context.Context, lessonID, ownerID uuid.UUID, req request.UpdateLessonRequest) (response.LessonResponse, error)
	deleteLessonFn         func(ctx context.Context, lessonID, ownerID uuid.UUID) error
}

func (m *mockLessonService) GetLessonByID(ctx context.Context, lessonID, ownerID uuid.UUID) (response.LessonResponse, error) {
	if m.getLessonByIDFn != nil {
		return m.getLessonByIDFn(ctx, lessonID, ownerID)
	}
	return response.LessonResponse{}, nil
}

func (m *mockLessonService) GetLessonDetailsByID(ctx context.Context, lessonID, ownerID uuid.UUID) (response.LessonDetailsResponse, error) {
	if m.getLessonDetailsByIDFn != nil {
		return m.getLessonDetailsByIDFn(ctx, lessonID, ownerID)
	}
	return response.LessonDetailsResponse{}, nil
}

func (m *mockLessonService) CreateLesson(ctx context.Context, req request.CreateLessonRequest, ownerID uuid.UUID) (response.LessonResponse, error) {
	if m.createLessonFn != nil {
		return m.createLessonFn(ctx, req, ownerID)
	}
	return response.LessonResponse{}, nil
}

func (m *mockLessonService) UpdateLesson(ctx context.Context, lessonID, ownerID uuid.UUID, req request.UpdateLessonRequest) (response.LessonResponse, error) {
	if m.updateLessonFn != nil {
		return m.updateLessonFn(ctx, lessonID, ownerID, req)
	}
	return response.LessonResponse{}, nil
}

func (m *mockLessonService) DeleteLesson(ctx context.Context, lessonID, ownerID uuid.UUID) error {
	if m.deleteLessonFn != nil {
		return m.deleteLessonFn(ctx, lessonID, ownerID)
	}
	return nil
}

func (m *mockLessonService) GetLessonsByGroupIDAndDateRange(ctx context.Context, groupID, ownerID uuid.UUID, from, to time.Time) ([]response.LessonResponse, error) {
	return nil, nil
}

func (m *mockLessonService) GetLessonsByIDs(ctx context.Context, lessonIDs []uuid.UUID, ownerID uuid.UUID) ([]response.LessonResponse, error) {
	return nil, nil
}

func setupLessonRouter(svc lessonService, user security.JwtUser) *gin.Engine {
	return testutil.SetupTestRouter(user, func(rg *gin.RouterGroup) {
		NewHandler(svc).RegisterRoutes(rg)
	})
}

func TestLessonHandler_GetLessonDetails(t *testing.T) {
	testUser := security.JwtUser{ID: uuid.New(), Email: "coach@example.com"}
	lessonID := uuid.New()

	t.Run("Unauthorized", func(t *testing.T) {
		r := setupLessonRouter(&mockLessonService{}, security.JwtUser{})
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodGet, "/api/v1/lessons/"+lessonID.String()+"/details", nil)
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusUnauthorized, w.Code)
	})

	t.Run("InvalidLessonID", func(t *testing.T) {
		r := setupLessonRouter(&mockLessonService{}, testUser)
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodGet, "/api/v1/lessons/invalid-uuid/details", nil)
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusBadRequest, w.Code)
	})

	t.Run("NotFound", func(t *testing.T) {
		mockSvc := &mockLessonService{
			getLessonDetailsByIDFn: func(ctx context.Context, lID, ownerID uuid.UUID) (response.LessonDetailsResponse, error) {
				return response.LessonDetailsResponse{}, pkgerrors.NewNotFound("Lesson", lID, ownerID)
			},
		}

		r := setupLessonRouter(mockSvc, testUser)
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodGet, "/api/v1/lessons/"+lessonID.String()+"/details", nil)
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusNotFound, w.Code)
	})

	t.Run("Success", func(t *testing.T) {
		mockSvc := &mockLessonService{
			getLessonDetailsByIDFn: func(ctx context.Context, lID, ownerID uuid.UUID) (response.LessonDetailsResponse, error) {
				assert.Equal(t, lessonID, lID)
				assert.Equal(t, testUser.ID, ownerID)
				return response.LessonDetailsResponse{
					ID:   lessonID,
					Date: time.Date(2026, 10, 17, 10, 0, 0, 0, time.UTC),
				}, nil
			},
		}

		r := setupLessonRouter(mockSvc, testUser)
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodGet, "/api/v1/lessons/"+lessonID.String()+"/details", nil)
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusOK, w.Code)
		var res response.LessonDetailsResponse
		err := json.Unmarshal(w.Body.Bytes(), &res)
		require.NoError(t, err)
		assert.Equal(t, lessonID, res.ID)
	})

	t.Run("InternalServerError", func(t *testing.T) {
		mockSvc := &mockLessonService{
			getLessonDetailsByIDFn: func(ctx context.Context, lID, ownerID uuid.UUID) (response.LessonDetailsResponse, error) {
				return response.LessonDetailsResponse{}, assert.AnError
			},
		}

		r := setupLessonRouter(mockSvc, testUser)
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodGet, "/api/v1/lessons/"+lessonID.String()+"/details", nil)
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusInternalServerError, w.Code)
	})
}

func TestLessonHandler_CreateLesson(t *testing.T) {
	testUser := security.JwtUser{ID: uuid.New(), Email: "coach@example.com"}

	t.Run("InvalidJSON", func(t *testing.T) {
		r := setupLessonRouter(&mockLessonService{}, testUser)
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodPost, "/api/v1/lessons", bytes.NewBufferString(`{invalid`))
		req.Header.Set("Content-Type", "application/json")
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusBadRequest, w.Code)
	})

	t.Run("MissingRequiredDate", func(t *testing.T) {
		r := setupLessonRouter(&mockLessonService{}, testUser)
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodPost, "/api/v1/lessons", bytes.NewBufferString(`{"students":[]}`))
		req.Header.Set("Content-Type", "application/json")
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusBadRequest, w.Code)
	})

	t.Run("Success", func(t *testing.T) {
		lessonDate := time.Date(2026, 10, 17, 10, 0, 0, 0, time.UTC)
		expectedID := uuid.New()

		mockSvc := &mockLessonService{
			createLessonFn: func(ctx context.Context, req request.CreateLessonRequest, ownerID uuid.UUID) (response.LessonResponse, error) {
				assert.Equal(t, testUser.ID, ownerID)
				assert.True(t, lessonDate.Equal(req.Date))
				return response.LessonResponse{ID: expectedID, Date: req.Date}, nil
			},
		}

		r := setupLessonRouter(mockSvc, testUser)
		w := httptest.NewRecorder()
		payload := `{"date":"` + lessonDate.Format(time.RFC3339) + `"}`
		req := httptest.NewRequest(http.MethodPost, "/api/v1/lessons", bytes.NewBufferString(payload))
		req.Header.Set("Content-Type", "application/json")
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusCreated, w.Code)
	})

	t.Run("InternalServerError", func(t *testing.T) {
		lessonDate := time.Date(2026, 10, 17, 10, 0, 0, 0, time.UTC)
		mockSvc := &mockLessonService{
			createLessonFn: func(ctx context.Context, req request.CreateLessonRequest, ownerID uuid.UUID) (response.LessonResponse, error) {
				return response.LessonResponse{}, assert.AnError
			},
		}

		r := setupLessonRouter(mockSvc, testUser)
		w := httptest.NewRecorder()
		payload := `{"date":"` + lessonDate.Format(time.RFC3339) + `"}`
		req := httptest.NewRequest(http.MethodPost, "/api/v1/lessons", bytes.NewBufferString(payload))
		req.Header.Set("Content-Type", "application/json")
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusInternalServerError, w.Code)
	})
}

func TestLessonHandler_UpdateLesson(t *testing.T) {
	testUser := security.JwtUser{ID: uuid.New(), Email: "coach@example.com"}
	lessonID := uuid.New()

	t.Run("InvalidLessonID", func(t *testing.T) {
		r := setupLessonRouter(&mockLessonService{}, testUser)
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodPatch, "/api/v1/lessons/bad-id", bytes.NewBufferString(`{}`))
		req.Header.Set("Content-Type", "application/json")
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusBadRequest, w.Code)
	})

	t.Run("InvalidJSON", func(t *testing.T) {
		r := setupLessonRouter(&mockLessonService{}, testUser)
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodPatch, "/api/v1/lessons/"+lessonID.String(), bytes.NewBufferString(`{invalid`))
		req.Header.Set("Content-Type", "application/json")
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusBadRequest, w.Code)
	})

	t.Run("Success", func(t *testing.T) {
		newDate := time.Date(2026, 10, 20, 15, 0, 0, 0, time.UTC)
		mockSvc := &mockLessonService{
			updateLessonFn: func(ctx context.Context, lID, ownerID uuid.UUID, req request.UpdateLessonRequest) (response.LessonResponse, error) {
				assert.Equal(t, lessonID, lID)
				assert.Equal(t, testUser.ID, ownerID)
				require.NotNil(t, req.Date)
				assert.True(t, newDate.Equal(*req.Date))
				return response.LessonResponse{ID: lessonID, Date: *req.Date}, nil
			},
		}

		r := setupLessonRouter(mockSvc, testUser)
		w := httptest.NewRecorder()
		payload := `{"date":"` + newDate.Format(time.RFC3339) + `"}`
		req := httptest.NewRequest(http.MethodPatch, "/api/v1/lessons/"+lessonID.String(), bytes.NewBufferString(payload))
		req.Header.Set("Content-Type", "application/json")
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusOK, w.Code)
	})

	t.Run("NotFound", func(t *testing.T) {
		mockSvc := &mockLessonService{
			updateLessonFn: func(ctx context.Context, lID, ownerID uuid.UUID, req request.UpdateLessonRequest) (response.LessonResponse, error) {
				return response.LessonResponse{}, pkgerrors.NewNotFound("Lesson", lID, ownerID)
			},
		}

		r := setupLessonRouter(mockSvc, testUser)
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodPatch, "/api/v1/lessons/"+lessonID.String(), bytes.NewBufferString(`{}`))
		req.Header.Set("Content-Type", "application/json")
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusNotFound, w.Code)
	})

	t.Run("InternalServerError", func(t *testing.T) {
		mockSvc := &mockLessonService{
			updateLessonFn: func(ctx context.Context, lID, ownerID uuid.UUID, req request.UpdateLessonRequest) (response.LessonResponse, error) {
				return response.LessonResponse{}, assert.AnError
			},
		}

		r := setupLessonRouter(mockSvc, testUser)
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodPatch, "/api/v1/lessons/"+lessonID.String(), bytes.NewBufferString(`{}`))
		req.Header.Set("Content-Type", "application/json")
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusInternalServerError, w.Code)
	})
}

func TestLessonHandler_DeleteLesson(t *testing.T) {
	testUser := security.JwtUser{ID: uuid.New(), Email: "coach@example.com"}
	lessonID := uuid.New()

	t.Run("InvalidLessonID", func(t *testing.T) {
		r := setupLessonRouter(&mockLessonService{}, testUser)
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodDelete, "/api/v1/lessons/bad-id", nil)
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusBadRequest, w.Code)
	})

	t.Run("Success", func(t *testing.T) {
		called := false
		mockSvc := &mockLessonService{
			deleteLessonFn: func(ctx context.Context, lID, ownerID uuid.UUID) error {
				assert.Equal(t, lessonID, lID)
				assert.Equal(t, testUser.ID, ownerID)
				called = true
				return nil
			},
		}

		r := setupLessonRouter(mockSvc, testUser)
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodDelete, "/api/v1/lessons/"+lessonID.String(), nil)
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusNoContent, w.Code)
		assert.True(t, called)
	})

	t.Run("NotFound", func(t *testing.T) {
		mockSvc := &mockLessonService{
			deleteLessonFn: func(ctx context.Context, lID, ownerID uuid.UUID) error {
				return pkgerrors.NewNotFound("Lesson", lID, ownerID)
			},
		}

		r := setupLessonRouter(mockSvc, testUser)
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodDelete, "/api/v1/lessons/"+lessonID.String(), nil)
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusNotFound, w.Code)
	})

	t.Run("InternalServerError", func(t *testing.T) {
		mockSvc := &mockLessonService{
			deleteLessonFn: func(ctx context.Context, lID, ownerID uuid.UUID) error {
				return assert.AnError
			},
		}

		r := setupLessonRouter(mockSvc, testUser)
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodDelete, "/api/v1/lessons/"+lessonID.String(), nil)
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusInternalServerError, w.Code)
	})
}
