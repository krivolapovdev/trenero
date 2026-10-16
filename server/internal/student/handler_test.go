package student

import (
	"bytes"
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/krivolapovdev/trenerio/pkg/models"
	"github.com/krivolapovdev/trenerio/pkg/security"
	"github.com/krivolapovdev/trenerio/pkg/types"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

type mockStudentService struct {
	getAllStudentsSummaryFn func(ctx context.Context, ownerID uuid.UUID) ([]models.StudentSummaryResponse, error)
	getStudentDetailsByIDFn func(ctx context.Context, studentID, ownerID uuid.UUID) (models.StudentResponse, error)
	createStudentFn         func(ctx context.Context, req models.CreateStudentRequest, ownerID uuid.UUID) (models.StudentResponse, error)
	deleteStudentFn         func(ctx context.Context, studentID, ownerID uuid.UUID) error
}

func (m *mockStudentService) GetAllStudents(ctx context.Context, ownerID uuid.UUID) ([]models.StudentResponse, error) {
	return nil, nil
}
func (m *mockStudentService) GetStudentsByIDs(ctx context.Context, studentIDs []uuid.UUID, ownerID uuid.UUID) ([]models.StudentResponse, error) {
	return nil, nil
}
func (m *mockStudentService) GetAllStudentsSummary(ctx context.Context, ownerID uuid.UUID) ([]models.StudentSummaryResponse, error) {
	if m.getAllStudentsSummaryFn != nil {
		return m.getAllStudentsSummaryFn(ctx, ownerID)
	}
	return nil, nil
}
func (m *mockStudentService) GetStudentDetailsByID(ctx context.Context, studentID, ownerID uuid.UUID) (models.StudentResponse, error) {
	if m.getStudentDetailsByIDFn != nil {
		return m.getStudentDetailsByIDFn(ctx, studentID, ownerID)
	}
	return models.StudentResponse{}, nil
}
func (m *mockStudentService) GetStudentVisits(ctx context.Context, studentID, ownerID uuid.UUID, from, to *time.Time) ([]models.VisitWithLessonResponse, error) {
	return nil, nil
}
func (m *mockStudentService) GetStudentPayments(ctx context.Context, studentID, ownerID uuid.UUID) ([]models.TransactionResponse, error) {
	return nil, nil
}
func (m *mockStudentService) CreateStudent(ctx context.Context, req models.CreateStudentRequest, ownerID uuid.UUID) (models.StudentResponse, error) {
	if m.createStudentFn != nil {
		return m.createStudentFn(ctx, req, ownerID)
	}
	return models.StudentResponse{}, nil
}
func (m *mockStudentService) CreateStudentPayment(ctx context.Context, studentID, ownerID uuid.UUID, req models.CreateStudentPaymentRequest) (models.TransactionResponse, error) {
	return models.TransactionResponse{}, nil
}
func (m *mockStudentService) UpdateStudent(ctx context.Context, studentID, ownerID uuid.UUID, updates map[string]any) (models.StudentResponse, error) {
	return models.StudentResponse{}, nil
}
func (m *mockStudentService) DeleteStudent(ctx context.Context, studentID, ownerID uuid.UUID) error {
	if m.deleteStudentFn != nil {
		return m.deleteStudentFn(ctx, studentID, ownerID)
	}
	return nil
}
func (m *mockStudentService) ComputeStudentStatuses(student models.StudentResponse, visits []models.VisitResponse, payments []models.TransactionResponse, lessonsMap map[uuid.UUID]models.LessonResponse, groupLessonsMap map[uuid.UUID]models.LessonResponse, today time.Time) []types.StudentStatus {
	return nil
}

func setupStudentRouter(svc Service, user security.JwtUser) *gin.Engine {
	gin.SetMode(gin.TestMode)
	r := gin.New()
	r.Use(func(c *gin.Context) {
		if user.ID != uuid.Nil {
			c.Set(types.ContextKeyJWTUser, user)
		}
		c.Next()
	})
	h := NewHandler(svc)
	h.RegisterRoutes(r.Group("/api/v1"))
	return r
}

func TestStudentHandler_GetAllStudentsSummary(t *testing.T) {
	testUser := security.JwtUser{ID: uuid.New(), Email: "coach@trenerio.ru"}

	t.Run("Unauthorized", func(t *testing.T) {
		r := setupStudentRouter(&mockStudentService{}, security.JwtUser{})
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodGet, "/api/v1/students/overview", nil)
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusUnauthorized, w.Code)
	})

	t.Run("Success", func(t *testing.T) {
		expected := []models.StudentSummaryResponse{
			{
				ID:       uuid.New(),
				FullName: "Ivan Ivanov",
			},
		}

		mockSvc := &mockStudentService{
			getAllStudentsSummaryFn: func(ctx context.Context, ownerID uuid.UUID) ([]models.StudentSummaryResponse, error) {
				assert.Equal(t, testUser.ID, ownerID)
				return expected, nil
			},
		}

		r := setupStudentRouter(mockSvc, testUser)
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodGet, "/api/v1/students/overview", nil)
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusOK, w.Code)
		var actual []models.StudentSummaryResponse
		err := json.Unmarshal(w.Body.Bytes(), &actual)
		require.NoError(t, err)
		assert.Len(t, actual, 1)
		assert.Equal(t, "Ivan Ivanov", actual[0].FullName)
	})
}

func TestStudentHandler_CreateStudent(t *testing.T) {
	testUser := security.JwtUser{ID: uuid.New(), Email: "coach@trenerio.ru"}

	t.Run("Success", func(t *testing.T) {
		expectedID := uuid.New()
		mockSvc := &mockStudentService{
			createStudentFn: func(ctx context.Context, req models.CreateStudentRequest, ownerID uuid.UUID) (models.StudentResponse, error) {
				assert.Equal(t, "Anna Smith", req.FullName)
				assert.Equal(t, testUser.ID, ownerID)
				return models.StudentResponse{
					ID:       expectedID,
					FullName: req.FullName,
				}, nil
			},
		}

		r := setupStudentRouter(mockSvc, testUser)
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodPost, "/api/v1/students", bytes.NewBufferString(`{"fullName":"Anna Smith"}`))
		req.Header.Set("Content-Type", "application/json")
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusCreated, w.Code)
		var actual models.StudentResponse
		err := json.Unmarshal(w.Body.Bytes(), &actual)
		require.NoError(t, err)
		assert.Equal(t, expectedID, actual.ID)
		assert.Equal(t, "Anna Smith", actual.FullName)
	})

	t.Run("InvalidJSON", func(t *testing.T) {
		r := setupStudentRouter(&mockStudentService{}, testUser)
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodPost, "/api/v1/students", bytes.NewBufferString(`malformed`))
		req.Header.Set("Content-Type", "application/json")
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusBadRequest, w.Code)
	})
}

func TestStudentHandler_DeleteStudent(t *testing.T) {
	testUser := security.JwtUser{ID: uuid.New(), Email: "coach@trenerio.ru"}

	t.Run("InvalidUUID", func(t *testing.T) {
		r := setupStudentRouter(&mockStudentService{}, testUser)
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodDelete, "/api/v1/students/not-a-uuid", nil)
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusBadRequest, w.Code)
	})

	t.Run("Success", func(t *testing.T) {
		targetID := uuid.New()
		called := false
		mockSvc := &mockStudentService{
			deleteStudentFn: func(ctx context.Context, studentID, ownerID uuid.UUID) error {
				assert.Equal(t, targetID, studentID)
				assert.Equal(t, testUser.ID, ownerID)
				called = true
				return nil
			},
		}

		r := setupStudentRouter(mockSvc, testUser)
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodDelete, "/api/v1/students/"+targetID.String(), nil)
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusNoContent, w.Code)
		assert.True(t, called)
	})
}
