package transaction

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

type mockTxService struct {
	getPaginatedTransactionsFn func(ctx context.Context, page, size int, ownerID uuid.UUID) (response.PageTransactionResponse, error)
	createTransactionFn        func(ctx context.Context, req request.CreateTransactionRequest, ownerID uuid.UUID) (response.TransactionResponse, error)
	updateTransactionFn        func(ctx context.Context, txID, ownerID uuid.UUID, updates map[string]any) (response.TransactionResponse, error)
	deleteTransactionFn        func(ctx context.Context, txID, ownerID uuid.UUID) error
}

func (m *mockTxService) GetPaginatedTransactions(ctx context.Context, page, size int, ownerID uuid.UUID) (response.PageTransactionResponse, error) {
	if m.getPaginatedTransactionsFn != nil {
		return m.getPaginatedTransactionsFn(ctx, page, size, ownerID)
	}
	return response.PageTransactionResponse{}, nil
}

func (m *mockTxService) GetTransactionsBetween(ctx context.Context, startDate, endDate time.Time, ownerID uuid.UUID) ([]response.TransactionResponse, error) {
	return nil, nil
}

func (m *mockTxService) GetTransactionsByStudentID(ctx context.Context, studentID, ownerID uuid.UUID) ([]response.TransactionResponse, error) {
	return nil, nil
}

func (m *mockTxService) GetTransactionsByStudentIDs(ctx context.Context, studentIDs []uuid.UUID, ownerID uuid.UUID) (map[uuid.UUID][]response.TransactionResponse, error) {
	return nil, nil
}

func (m *mockTxService) CreateTransaction(ctx context.Context, req request.CreateTransactionRequest, ownerID uuid.UUID) (response.TransactionResponse, error) {
	if m.createTransactionFn != nil {
		return m.createTransactionFn(ctx, req, ownerID)
	}
	return response.TransactionResponse{}, nil
}

func (m *mockTxService) CreateStudentPayment(ctx context.Context, studentID uuid.UUID, amount float64, date, paidUntil time.Time, ownerID uuid.UUID) (response.TransactionResponse, error) {
	return response.TransactionResponse{}, nil
}

func (m *mockTxService) UpdateTransaction(ctx context.Context, transactionID, ownerID uuid.UUID, updates map[string]any) (response.TransactionResponse, error) {
	if m.updateTransactionFn != nil {
		return m.updateTransactionFn(ctx, transactionID, ownerID, updates)
	}
	return response.TransactionResponse{}, nil
}

func (m *mockTxService) DeleteTransaction(ctx context.Context, transactionID, ownerID uuid.UUID) error {
	if m.deleteTransactionFn != nil {
		return m.deleteTransactionFn(ctx, transactionID, ownerID)
	}
	return nil
}

func setupTxRouter(svc transactionService, user security.JwtUser) *gin.Engine {
	return testutil.SetupTestRouter(user, func(rg *gin.RouterGroup) {
		NewHandler(svc).RegisterRoutes(rg)
	})
}

func TestTransactionHandler_GetPaginatedTransactions(t *testing.T) {
	testUser := security.JwtUser{ID: uuid.New(), Email: "coach@example.com"}

	t.Run("Unauthorized", func(t *testing.T) {
		r := setupTxRouter(&mockTxService{}, security.JwtUser{})
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodGet, "/api/v1/transactions", nil)
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusUnauthorized, w.Code)
	})

	t.Run("SuccessWithDefaults", func(t *testing.T) {
		mockSvc := &mockTxService{
			getPaginatedTransactionsFn: func(ctx context.Context, page, size int, ownerID uuid.UUID) (response.PageTransactionResponse, error) {
				assert.Equal(t, 1, page)
				assert.Equal(t, 20, size)
				assert.Equal(t, testUser.ID, ownerID)
				return response.PageTransactionResponse{
					Number:        page,
					Size:          size,
					TotalElements: 1,
					TotalPages:    1,
				}, nil
			},
		}

		r := setupTxRouter(mockSvc, testUser)
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodGet, "/api/v1/transactions", nil)
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusOK, w.Code)
		var actual response.PageTransactionResponse
		err := json.Unmarshal(w.Body.Bytes(), &actual)
		require.NoError(t, err)
		assert.Equal(t, 1, actual.Number)
	})

	t.Run("SuccessWithQueryParams", func(t *testing.T) {
		mockSvc := &mockTxService{
			getPaginatedTransactionsFn: func(ctx context.Context, page, size int, ownerID uuid.UUID) (response.PageTransactionResponse, error) {
				assert.Equal(t, 2, page)
				assert.Equal(t, 50, size)
				return response.PageTransactionResponse{Number: page, Size: size}, nil
			},
		}

		r := setupTxRouter(mockSvc, testUser)
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodGet, "/api/v1/transactions?page=2&size=50", nil)
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusOK, w.Code)
	})

	t.Run("InternalServerError", func(t *testing.T) {
		mockSvc := &mockTxService{
			getPaginatedTransactionsFn: func(ctx context.Context, page, size int, ownerID uuid.UUID) (response.PageTransactionResponse, error) {
				return response.PageTransactionResponse{}, assert.AnError
			},
		}

		r := setupTxRouter(mockSvc, testUser)
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodGet, "/api/v1/transactions", nil)
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusInternalServerError, w.Code)
	})
}

func TestTransactionHandler_CreateTransaction(t *testing.T) {
	testUser := security.JwtUser{ID: uuid.New(), Email: "coach@example.com"}

	t.Run("InvalidJSON", func(t *testing.T) {
		r := setupTxRouter(&mockTxService{}, testUser)
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodPost, "/api/v1/transactions", bytes.NewBufferString(`{invalid`))
		req.Header.Set("Content-Type", "application/json")
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusBadRequest, w.Code)
	})

	t.Run("Success", func(t *testing.T) {
		txDate := time.Date(2026, 10, 17, 10, 0, 0, 0, time.UTC)
		expectedID := uuid.New()

		mockSvc := &mockTxService{
			createTransactionFn: func(ctx context.Context, req request.CreateTransactionRequest, ownerID uuid.UUID) (response.TransactionResponse, error) {
				assert.Equal(t, testUser.ID, ownerID)
				assert.Equal(t, 2500.0, req.Amount)
				return response.TransactionResponse{ID: expectedID, Amount: req.Amount}, nil
			},
		}

		r := setupTxRouter(mockSvc, testUser)
		w := httptest.NewRecorder()
		payload := `{"amount":2500.0,"type":"INCOME","date":"` + txDate.Format(time.RFC3339) + `"}`
		req := httptest.NewRequest(http.MethodPost, "/api/v1/transactions", bytes.NewBufferString(payload))
		req.Header.Set("Content-Type", "application/json")
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusCreated, w.Code)
		var actual response.TransactionResponse
		err := json.Unmarshal(w.Body.Bytes(), &actual)
		require.NoError(t, err)
		assert.Equal(t, expectedID, actual.ID)
	})

	t.Run("InternalServerError", func(t *testing.T) {
		mockSvc := &mockTxService{
			createTransactionFn: func(ctx context.Context, req request.CreateTransactionRequest, ownerID uuid.UUID) (response.TransactionResponse, error) {
				return response.TransactionResponse{}, assert.AnError
			},
		}

		r := setupTxRouter(mockSvc, testUser)
		w := httptest.NewRecorder()
		payload := `{"amount":2500.0,"type":"INCOME","date":"2026-10-17T10:00:00Z"}`
		req := httptest.NewRequest(http.MethodPost, "/api/v1/transactions", bytes.NewBufferString(payload))
		req.Header.Set("Content-Type", "application/json")
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusInternalServerError, w.Code)
	})
}

func TestTransactionHandler_UpdateTransaction(t *testing.T) {
	testUser := security.JwtUser{ID: uuid.New(), Email: "coach@example.com"}
	txID := uuid.New()

	t.Run("InvalidTxID", func(t *testing.T) {
		r := setupTxRouter(&mockTxService{}, testUser)
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodPatch, "/api/v1/transactions/bad-id", bytes.NewBufferString(`{}`))
		req.Header.Set("Content-Type", "application/json")
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusBadRequest, w.Code)
	})

	t.Run("InvalidJSON", func(t *testing.T) {
		r := setupTxRouter(&mockTxService{}, testUser)
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodPatch, "/api/v1/transactions/"+txID.String(), bytes.NewBufferString(`{bad`))
		req.Header.Set("Content-Type", "application/json")
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusBadRequest, w.Code)
	})

	t.Run("Success", func(t *testing.T) {
		mockSvc := &mockTxService{
			updateTransactionFn: func(ctx context.Context, id, ownerID uuid.UUID, updates map[string]any) (response.TransactionResponse, error) {
				assert.Equal(t, txID, id)
				assert.Equal(t, testUser.ID, ownerID)
				assert.Equal(t, 3000.0, updates["amount"])
				return response.TransactionResponse{ID: txID, Amount: 3000.0}, nil
			},
		}

		r := setupTxRouter(mockSvc, testUser)
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodPatch, "/api/v1/transactions/"+txID.String(), bytes.NewBufferString(`{"amount":3000.0}`))
		req.Header.Set("Content-Type", "application/json")
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusOK, w.Code)
	})

	t.Run("NotFound", func(t *testing.T) {
		mockSvc := &mockTxService{
			updateTransactionFn: func(ctx context.Context, id, ownerID uuid.UUID, updates map[string]any) (response.TransactionResponse, error) {
				return response.TransactionResponse{}, pkgerrors.NewNotFound("Transaction", id, ownerID)
			},
		}

		r := setupTxRouter(mockSvc, testUser)
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodPatch, "/api/v1/transactions/"+txID.String(), bytes.NewBufferString(`{"amount":3000.0}`))
		req.Header.Set("Content-Type", "application/json")
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusNotFound, w.Code)
	})

	t.Run("InternalServerError", func(t *testing.T) {
		mockSvc := &mockTxService{
			updateTransactionFn: func(ctx context.Context, id, ownerID uuid.UUID, updates map[string]any) (response.TransactionResponse, error) {
				return response.TransactionResponse{}, assert.AnError
			},
		}

		r := setupTxRouter(mockSvc, testUser)
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodPatch, "/api/v1/transactions/"+txID.String(), bytes.NewBufferString(`{"amount":3000.0}`))
		req.Header.Set("Content-Type", "application/json")
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusInternalServerError, w.Code)
	})
}

func TestTransactionHandler_DeleteTransaction(t *testing.T) {
	testUser := security.JwtUser{ID: uuid.New(), Email: "coach@example.com"}
	txID := uuid.New()

	t.Run("InvalidTxID", func(t *testing.T) {
		r := setupTxRouter(&mockTxService{}, testUser)
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodDelete, "/api/v1/transactions/bad-id", nil)
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusBadRequest, w.Code)
	})

	t.Run("Success", func(t *testing.T) {
		called := false
		mockSvc := &mockTxService{
			deleteTransactionFn: func(ctx context.Context, id, ownerID uuid.UUID) error {
				assert.Equal(t, txID, id)
				assert.Equal(t, testUser.ID, ownerID)
				called = true
				return nil
			},
		}

		r := setupTxRouter(mockSvc, testUser)
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodDelete, "/api/v1/transactions/"+txID.String(), nil)
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusNoContent, w.Code)
		assert.True(t, called)
	})

	t.Run("NotFound", func(t *testing.T) {
		mockSvc := &mockTxService{
			deleteTransactionFn: func(ctx context.Context, id, ownerID uuid.UUID) error {
				return pkgerrors.NewNotFound("Transaction", txID, ownerID)
			},
		}

		r := setupTxRouter(mockSvc, testUser)
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodDelete, "/api/v1/transactions/"+txID.String(), nil)
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusNotFound, w.Code)
	})

	t.Run("InternalServerError", func(t *testing.T) {
		mockSvc := &mockTxService{
			deleteTransactionFn: func(ctx context.Context, id, ownerID uuid.UUID) error {
				return assert.AnError
			},
		}

		r := setupTxRouter(mockSvc, testUser)
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodDelete, "/api/v1/transactions/"+txID.String(), nil)
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusInternalServerError, w.Code)
	})
}
