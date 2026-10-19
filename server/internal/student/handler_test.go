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
	"github.com/krivolapovdev/trenerio/internal/auth"
	pkgerrors "github.com/krivolapovdev/trenerio/internal/shared/errors"
	"github.com/krivolapovdev/trenerio/internal/shared/harness"
	"github.com/krivolapovdev/trenerio/internal/shared/request"
	"github.com/krivolapovdev/trenerio/internal/shared/response"
	"github.com/krivolapovdev/trenerio/internal/transaction"
	"github.com/krivolapovdev/trenerio/internal/visit"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

type mockStudentService struct {
	getAllStudentsSummaryFn func(ctx context.Context, ownerID uuid.UUID) ([]StudentSummaryResponse, error)
	getStudentDetailsByIDFn func(ctx context.Context, studentID, ownerID uuid.UUID) (response.StudentResponse, error)
	getStudentVisitsFn      func(ctx context.Context, studentID, ownerID uuid.UUID, from, to *time.Time) ([]response.VisitWithLessonResponse, error)
	getStudentPaymentsFn    func(ctx context.Context, studentID, ownerID uuid.UUID) ([]transaction.TransactionResponse, error)
	createStudentFn         func(ctx context.Context, req request.CreateStudentRequest, ownerID uuid.UUID) (response.StudentResponse, error)
	createStudentPaymentFn  func(ctx context.Context, studentID, ownerID uuid.UUID, req request.CreateStudentPaymentRequest) (transaction.TransactionResponse, error)
	updateStudentFn         func(ctx context.Context, studentID, ownerID uuid.UUID, updates map[string]any) (response.StudentResponse, error)
	deleteStudentFn         func(ctx context.Context, studentID, ownerID uuid.UUID) error
}

func (m *mockStudentService) GetAllStudents(ctx context.Context, ownerID uuid.UUID) ([]response.StudentResponse, error) {
	return nil, nil
}
func (m *mockStudentService) GetStudentsByIDs(ctx context.Context, studentIDs []uuid.UUID, ownerID uuid.UUID) ([]response.StudentResponse, error) {
	return nil, nil
}
func (m *mockStudentService) GetAllStudentsSummary(ctx context.Context, ownerID uuid.UUID) ([]StudentSummaryResponse, error) {
	if m.getAllStudentsSummaryFn != nil {
		return m.getAllStudentsSummaryFn(ctx, ownerID)
	}
	return nil, nil
}
func (m *mockStudentService) GetStudentDetailsByID(ctx context.Context, studentID, ownerID uuid.UUID) (response.StudentResponse, error) {
	if m.getStudentDetailsByIDFn != nil {
		return m.getStudentDetailsByIDFn(ctx, studentID, ownerID)
	}
	return response.StudentResponse{}, nil
}
func (m *mockStudentService) GetStudentVisits(ctx context.Context, studentID, ownerID uuid.UUID, from, to *time.Time) ([]response.VisitWithLessonResponse, error) {
	if m.getStudentVisitsFn != nil {
		return m.getStudentVisitsFn(ctx, studentID, ownerID, from, to)
	}
	return nil, nil
}
func (m *mockStudentService) GetStudentPayments(ctx context.Context, studentID, ownerID uuid.UUID) ([]transaction.TransactionResponse, error) {
	if m.getStudentPaymentsFn != nil {
		return m.getStudentPaymentsFn(ctx, studentID, ownerID)
	}
	return nil, nil
}
func (m *mockStudentService) CreateStudent(ctx context.Context, req request.CreateStudentRequest, ownerID uuid.UUID) (response.StudentResponse, error) {
	if m.createStudentFn != nil {
		return m.createStudentFn(ctx, req, ownerID)
	}
	return response.StudentResponse{}, nil
}
func (m *mockStudentService) CreateStudentPayment(ctx context.Context, studentID, ownerID uuid.UUID, req request.CreateStudentPaymentRequest) (transaction.TransactionResponse, error) {
	if m.createStudentPaymentFn != nil {
		return m.createStudentPaymentFn(ctx, studentID, ownerID, req)
	}
	return transaction.TransactionResponse{}, nil
}
func (m *mockStudentService) UpdateStudent(ctx context.Context, studentID, ownerID uuid.UUID, updates map[string]any) (response.StudentResponse, error) {
	if m.updateStudentFn != nil {
		return m.updateStudentFn(ctx, studentID, ownerID, updates)
	}
	return response.StudentResponse{}, nil
}
func (m *mockStudentService) DeleteStudent(ctx context.Context, studentID, ownerID uuid.UUID) error {
	if m.deleteStudentFn != nil {
		return m.deleteStudentFn(ctx, studentID, ownerID)
	}
	return nil
}
func (m *mockStudentService) ComputeStudentStatuses(student response.StudentResponse, visits []visit.VisitResponse, payments []transaction.TransactionResponse, lessonsMap map[uuid.UUID]response.LessonResponse, groupLessonsMap map[uuid.UUID]response.LessonResponse, today time.Time) []StudentStatus {
	return nil
}

func setupStudentRouter(svc studentService, user auth.JwtUser) *gin.Engine {
	return harness.SetupTestRouter(user, func(rg *gin.RouterGroup) {
		NewHandler(svc).RegisterRoutes(rg)
	})
}

func TestStudentHandler_GetAllStudentsSummary(t *testing.T) {
	testUser := auth.JwtUser{ID: uuid.New(), Email: "coach@trenerio.ru"}

	t.Run("Unauthorized", func(t *testing.T) {
		r := setupStudentRouter(&mockStudentService{}, auth.JwtUser{})
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodGet, "/api/v1/students/overview", nil)
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusUnauthorized, w.Code)
	})

	t.Run("Success", func(t *testing.T) {
		expected := []StudentSummaryResponse{
			{
				ID:       uuid.New(),
				FullName: "Ivan Ivanov",
			},
		}

		mockSvc := &mockStudentService{
			getAllStudentsSummaryFn: func(ctx context.Context, ownerID uuid.UUID) ([]StudentSummaryResponse, error) {
				assert.Equal(t, testUser.ID, ownerID)
				return expected, nil
			},
		}

		r := setupStudentRouter(mockSvc, testUser)
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodGet, "/api/v1/students/overview", nil)
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusOK, w.Code)
		var actual []StudentSummaryResponse
		err := json.Unmarshal(w.Body.Bytes(), &actual)
		require.NoError(t, err)
		assert.Len(t, actual, 1)
		assert.Equal(t, "Ivan Ivanov", actual[0].FullName)
	})

	t.Run("InternalServerError", func(t *testing.T) {
		mockSvc := &mockStudentService{
			getAllStudentsSummaryFn: func(ctx context.Context, ownerID uuid.UUID) ([]StudentSummaryResponse, error) {
				return nil, assert.AnError
			},
		}

		r := setupStudentRouter(mockSvc, testUser)
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodGet, "/api/v1/students/overview", nil)
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusInternalServerError, w.Code)
	})
}

func TestStudentHandler_CreateStudent(t *testing.T) {
	testUser := auth.JwtUser{ID: uuid.New(), Email: "coach@trenerio.ru"}

	t.Run("Success", func(t *testing.T) {
		expectedID := uuid.New()
		mockSvc := &mockStudentService{
			createStudentFn: func(ctx context.Context, req request.CreateStudentRequest, ownerID uuid.UUID) (response.StudentResponse, error) {
				assert.Equal(t, "Anna Smith", req.FullName)
				assert.Equal(t, testUser.ID, ownerID)
				return response.StudentResponse{
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
		var actual response.StudentResponse
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

	t.Run("BlankFullName", func(t *testing.T) {
		r := setupStudentRouter(&mockStudentService{}, testUser)
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodPost, "/api/v1/students", bytes.NewBufferString(`{"fullName":"   "}`))
		req.Header.Set("Content-Type", "application/json")
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusBadRequest, w.Code)
	})

	t.Run("TrimmedData", func(t *testing.T) {
		expectedID := uuid.New()
		mockSvc := &mockStudentService{
			createStudentFn: func(ctx context.Context, req request.CreateStudentRequest, ownerID uuid.UUID) (response.StudentResponse, error) {
				assert.Equal(t, "Anna Smith", req.FullName)
				require.NotNil(t, req.Phone)
				assert.Equal(t, "123456", *req.Phone)
				require.NotNil(t, req.Note)
				assert.Equal(t, "student note", *req.Note)
				return response.StudentResponse{
					ID:       expectedID,
					FullName: req.FullName,
					Phone:    req.Phone,
					Note:     req.Note,
				}, nil
			},
		}

		r := setupStudentRouter(mockSvc, testUser)
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodPost, "/api/v1/students", bytes.NewBufferString(`{"fullName":"  Anna Smith  ","phone":"  123456  ","note":"  student note  "}`))
		req.Header.Set("Content-Type", "application/json")
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusCreated, w.Code)
	})

	t.Run("InternalServerError", func(t *testing.T) {
		mockSvc := &mockStudentService{
			createStudentFn: func(ctx context.Context, req request.CreateStudentRequest, ownerID uuid.UUID) (response.StudentResponse, error) {
				return response.StudentResponse{}, assert.AnError
			},
		}

		r := setupStudentRouter(mockSvc, testUser)
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodPost, "/api/v1/students", bytes.NewBufferString(`{"fullName":"Anna Smith"}`))
		req.Header.Set("Content-Type", "application/json")
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusInternalServerError, w.Code)
	})
}

func TestStudentHandler_DeleteStudent(t *testing.T) {
	testUser := auth.JwtUser{ID: uuid.New(), Email: "coach@trenerio.ru"}

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

	t.Run("NotFound", func(t *testing.T) {
		targetID := uuid.New()
		mockSvc := &mockStudentService{
			deleteStudentFn: func(ctx context.Context, studentID, ownerID uuid.UUID) error {
				return pkgerrors.NewNotFound("Student", studentID, ownerID)
			},
		}

		r := setupStudentRouter(mockSvc, testUser)
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodDelete, "/api/v1/students/"+targetID.String(), nil)
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusNotFound, w.Code)
	})

	t.Run("InternalServerError", func(t *testing.T) {
		targetID := uuid.New()
		mockSvc := &mockStudentService{
			deleteStudentFn: func(ctx context.Context, studentID, ownerID uuid.UUID) error {
				return assert.AnError
			},
		}

		r := setupStudentRouter(mockSvc, testUser)
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodDelete, "/api/v1/students/"+targetID.String(), nil)
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusInternalServerError, w.Code)
	})
}

func TestStudentHandler_GetStudentVisits(t *testing.T) {
	testUser := auth.JwtUser{ID: uuid.New(), Email: "coach@trenerio.ru"}
	studentID := uuid.New()

	t.Run("InvalidStudentID", func(t *testing.T) {
		r := setupStudentRouter(&mockStudentService{}, testUser)
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodGet, "/api/v1/students/bad-id/visits", nil)
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusBadRequest, w.Code)
	})

	t.Run("SuccessWithoutDates", func(t *testing.T) {
		mockSvc := &mockStudentService{
			getStudentVisitsFn: func(ctx context.Context, sID, ownerID uuid.UUID, from, to *time.Time) ([]response.VisitWithLessonResponse, error) {
				assert.Equal(t, studentID, sID)
				assert.Equal(t, testUser.ID, ownerID)
				assert.Nil(t, from)
				assert.Nil(t, to)
				return []response.VisitWithLessonResponse{
					{
						Visit:  response.VisitResponse{ID: uuid.New()},
						Lesson: response.LessonResponse{ID: uuid.New()},
					},
				}, nil
			},
		}

		r := setupStudentRouter(mockSvc, testUser)
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodGet, "/api/v1/students/"+studentID.String()+"/visits", nil)
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusOK, w.Code)
	})

	t.Run("SuccessWithDates", func(t *testing.T) {
		fromDate := time.Date(2026, 1, 1, 0, 0, 0, 0, time.UTC)
		toDate := time.Date(2026, 1, 31, 0, 0, 0, 0, time.UTC)

		mockSvc := &mockStudentService{
			getStudentVisitsFn: func(ctx context.Context, sID, ownerID uuid.UUID, from, to *time.Time) ([]response.VisitWithLessonResponse, error) {
				require.NotNil(t, from)
				require.NotNil(t, to)
				assert.True(t, fromDate.Equal(*from))
				assert.True(t, toDate.Equal(*to))
				return []response.VisitWithLessonResponse{}, nil
			},
		}

		r := setupStudentRouter(mockSvc, testUser)
		w := httptest.NewRecorder()
		url := "/api/v1/students/" + studentID.String() + "/visits?from=" + fromDate.Format(time.RFC3339) + "&to=" + toDate.Format(time.RFC3339)
		req := httptest.NewRequest(http.MethodGet, url, nil)
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusOK, w.Code)
	})

	t.Run("InternalServerError", func(t *testing.T) {
		mockSvc := &mockStudentService{
			getStudentVisitsFn: func(ctx context.Context, sID, ownerID uuid.UUID, from, to *time.Time) ([]response.VisitWithLessonResponse, error) {
				return nil, assert.AnError
			},
		}

		r := setupStudentRouter(mockSvc, testUser)
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodGet, "/api/v1/students/"+studentID.String()+"/visits", nil)
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusInternalServerError, w.Code)
	})
}

func TestStudentHandler_GetStudentPayments(t *testing.T) {
	testUser := auth.JwtUser{ID: uuid.New(), Email: "coach@trenerio.ru"}
	studentID := uuid.New()

	t.Run("InvalidStudentID", func(t *testing.T) {
		r := setupStudentRouter(&mockStudentService{}, testUser)
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodGet, "/api/v1/students/invalid-uuid/payments", nil)
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusBadRequest, w.Code)
	})

	t.Run("Success", func(t *testing.T) {
		mockSvc := &mockStudentService{
			getStudentPaymentsFn: func(ctx context.Context, sID, ownerID uuid.UUID) ([]transaction.TransactionResponse, error) {
				assert.Equal(t, studentID, sID)
				assert.Equal(t, testUser.ID, ownerID)
				return []transaction.TransactionResponse{{ID: uuid.New(), Amount: 5000}}, nil
			},
		}

		r := setupStudentRouter(mockSvc, testUser)
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodGet, "/api/v1/students/"+studentID.String()+"/payments", nil)
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusOK, w.Code)
	})

	t.Run("InternalServerError", func(t *testing.T) {
		mockSvc := &mockStudentService{
			getStudentPaymentsFn: func(ctx context.Context, sID, ownerID uuid.UUID) ([]transaction.TransactionResponse, error) {
				return nil, assert.AnError
			},
		}

		r := setupStudentRouter(mockSvc, testUser)
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodGet, "/api/v1/students/"+studentID.String()+"/payments", nil)
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusInternalServerError, w.Code)
	})
}

func TestStudentHandler_CreateStudentPayment(t *testing.T) {
	testUser := auth.JwtUser{ID: uuid.New(), Email: "coach@trenerio.ru"}
	studentID := uuid.New()

	t.Run("InvalidStudentID", func(t *testing.T) {
		r := setupStudentRouter(&mockStudentService{}, testUser)
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodPost, "/api/v1/students/bad-id/payments", bytes.NewBufferString(`{}`))
		req.Header.Set("Content-Type", "application/json")
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusBadRequest, w.Code)
	})

	t.Run("InvalidJSON", func(t *testing.T) {
		r := setupStudentRouter(&mockStudentService{}, testUser)
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodPost, "/api/v1/students/"+studentID.String()+"/payments", bytes.NewBufferString(`{bad`))
		req.Header.Set("Content-Type", "application/json")
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusBadRequest, w.Code)
	})

	t.Run("Success", func(t *testing.T) {
		expectedID := uuid.New()
		paymentDate := time.Date(2026, 10, 17, 0, 0, 0, 0, time.UTC)
		paidUntil := time.Date(2026, 11, 17, 0, 0, 0, 0, time.UTC)

		mockSvc := &mockStudentService{
			createStudentPaymentFn: func(ctx context.Context, sID, ownerID uuid.UUID, req request.CreateStudentPaymentRequest) (transaction.TransactionResponse, error) {
				assert.Equal(t, studentID, sID)
				assert.Equal(t, testUser.ID, ownerID)
				assert.Equal(t, 4500.0, req.Amount)
				return transaction.TransactionResponse{ID: expectedID, Amount: req.Amount}, nil
			},
		}

		r := setupStudentRouter(mockSvc, testUser)
		w := httptest.NewRecorder()
		payload := `{"amount":4500.0,"date":"` + paymentDate.Format(time.RFC3339) + `","paidUntil":"` + paidUntil.Format(time.RFC3339) + `"}`
		req := httptest.NewRequest(http.MethodPost, "/api/v1/students/"+studentID.String()+"/payments", bytes.NewBufferString(payload))
		req.Header.Set("Content-Type", "application/json")
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusCreated, w.Code)
	})

	t.Run("InternalServerError", func(t *testing.T) {
		mockSvc := &mockStudentService{
			createStudentPaymentFn: func(ctx context.Context, sID, ownerID uuid.UUID, req request.CreateStudentPaymentRequest) (transaction.TransactionResponse, error) {
				return transaction.TransactionResponse{}, assert.AnError
			},
		}

		r := setupStudentRouter(mockSvc, testUser)
		w := httptest.NewRecorder()
		payload := `{"amount":4500.0,"date":"2026-10-17T00:00:00Z","paidUntil":"2026-11-17T00:00:00Z"}`
		req := httptest.NewRequest(http.MethodPost, "/api/v1/students/"+studentID.String()+"/payments", bytes.NewBufferString(payload))
		req.Header.Set("Content-Type", "application/json")
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusInternalServerError, w.Code)
	})
}

func TestStudentHandler_UpdateStudent(t *testing.T) {
	testUser := auth.JwtUser{ID: uuid.New(), Email: "coach@trenerio.ru"}
	studentID := uuid.New()

	t.Run("InvalidStudentID", func(t *testing.T) {
		r := setupStudentRouter(&mockStudentService{}, testUser)
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodPatch, "/api/v1/students/bad-id", bytes.NewBufferString(`{}`))
		req.Header.Set("Content-Type", "application/json")
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusBadRequest, w.Code)
	})

	t.Run("InvalidJSON", func(t *testing.T) {
		r := setupStudentRouter(&mockStudentService{}, testUser)
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodPatch, "/api/v1/students/"+studentID.String(), bytes.NewBufferString(`{bad`))
		req.Header.Set("Content-Type", "application/json")
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusBadRequest, w.Code)
	})

	t.Run("Success", func(t *testing.T) {
		mockSvc := &mockStudentService{
			updateStudentFn: func(ctx context.Context, sID, ownerID uuid.UUID, updates map[string]any) (response.StudentResponse, error) {
				assert.Equal(t, studentID, sID)
				assert.Equal(t, testUser.ID, ownerID)
				assert.Equal(t, "Boris", updates["fullName"])
				return response.StudentResponse{ID: studentID, FullName: "Boris"}, nil
			},
		}

		r := setupStudentRouter(mockSvc, testUser)
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodPatch, "/api/v1/students/"+studentID.String(), bytes.NewBufferString(`{"fullName":"Boris"}`))
		req.Header.Set("Content-Type", "application/json")
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusOK, w.Code)
	})

	t.Run("NotFound", func(t *testing.T) {
		mockSvc := &mockStudentService{
			updateStudentFn: func(ctx context.Context, sID, ownerID uuid.UUID, updates map[string]any) (response.StudentResponse, error) {
				return response.StudentResponse{}, pkgerrors.NewNotFound("Student", sID, ownerID)
			},
		}

		r := setupStudentRouter(mockSvc, testUser)
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodPatch, "/api/v1/students/"+studentID.String(), bytes.NewBufferString(`{"fullName":"Boris"}`))
		req.Header.Set("Content-Type", "application/json")
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusNotFound, w.Code)
	})

	t.Run("BlankFullName", func(t *testing.T) {
		r := setupStudentRouter(&mockStudentService{}, testUser)
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodPatch, "/api/v1/students/"+studentID.String(), bytes.NewBufferString(`{"fullName":"   "}`))
		req.Header.Set("Content-Type", "application/json")
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusBadRequest, w.Code)
	})

	t.Run("TrimmedData", func(t *testing.T) {
		mockSvc := &mockStudentService{
			updateStudentFn: func(ctx context.Context, sID, ownerID uuid.UUID, updates map[string]any) (response.StudentResponse, error) {
				assert.Equal(t, studentID, sID)
				assert.Equal(t, testUser.ID, ownerID)
				assert.Equal(t, "Boris", updates["fullName"])
				assert.Equal(t, "98765", updates["phone"])
				assert.Equal(t, "updated note", updates["note"])
				return response.StudentResponse{ID: studentID, FullName: "Boris"}, nil
			},
		}

		r := setupStudentRouter(mockSvc, testUser)
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodPatch, "/api/v1/students/"+studentID.String(), bytes.NewBufferString(`{"fullName":"  Boris  ","phone":"  98765  ","note":"  updated note  "}`))
		req.Header.Set("Content-Type", "application/json")
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusOK, w.Code)
	})

	t.Run("InternalServerError", func(t *testing.T) {
		mockSvc := &mockStudentService{
			updateStudentFn: func(ctx context.Context, sID, ownerID uuid.UUID, updates map[string]any) (response.StudentResponse, error) {
				return response.StudentResponse{}, assert.AnError
			},
		}

		r := setupStudentRouter(mockSvc, testUser)
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodPatch, "/api/v1/students/"+studentID.String(), bytes.NewBufferString(`{"fullName":"Boris"}`))
		req.Header.Set("Content-Type", "application/json")
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusInternalServerError, w.Code)
	})
}
