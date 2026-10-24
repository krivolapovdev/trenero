package roster

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
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

type mockRosterService struct {
	getAllRostersFn         func(ctx context.Context, ownerID uuid.UUID) ([]response.RosterResponse, error)
	getRosterByIDFn         func(ctx context.Context, rosterID, ownerID uuid.UUID) (response.RosterResponse, error)
	getRosterStudentsFn     func(ctx context.Context, rosterID, ownerID uuid.UUID) ([]response.StudentResponse, error)
	createRosterFn          func(ctx context.Context, req request.CreateRosterRequest, ownerID uuid.UUID) (response.RosterResponse, error)
	updateRosterFn          func(ctx context.Context, rosterID, ownerID uuid.UUID, updates map[string]any) (response.RosterResponse, error)
	deleteRosterFn          func(ctx context.Context, rosterID, ownerID uuid.UUID) error
	addStudentsFn           func(ctx context.Context, rosterID, ownerID uuid.UUID, studentIDs []uuid.UUID, note *string) (response.RosterResponse, error)
	updateParticipantNoteFn func(ctx context.Context, rosterID, studentID, ownerID uuid.UUID, note *string) error
	removeStudentFn         func(ctx context.Context, rosterID, studentID, ownerID uuid.UUID) error
}

func (m *mockRosterService) GetAllRosters(ctx context.Context, ownerID uuid.UUID) ([]response.RosterResponse, error) {
	if m.getAllRostersFn != nil {
		return m.getAllRostersFn(ctx, ownerID)
	}
	return nil, nil
}

func (m *mockRosterService) GetRosterByID(ctx context.Context, rosterID, ownerID uuid.UUID) (response.RosterResponse, error) {
	if m.getRosterByIDFn != nil {
		return m.getRosterByIDFn(ctx, rosterID, ownerID)
	}
	return response.RosterResponse{}, nil
}

func (m *mockRosterService) GetRosterStudents(ctx context.Context, rosterID, ownerID uuid.UUID) ([]response.StudentResponse, error) {
	if m.getRosterStudentsFn != nil {
		return m.getRosterStudentsFn(ctx, rosterID, ownerID)
	}
	return nil, nil
}

func (m *mockRosterService) CreateRoster(ctx context.Context, req request.CreateRosterRequest, ownerID uuid.UUID) (response.RosterResponse, error) {
	if m.createRosterFn != nil {
		return m.createRosterFn(ctx, req, ownerID)
	}
	return response.RosterResponse{}, nil
}

func (m *mockRosterService) UpdateRoster(ctx context.Context, rosterID, ownerID uuid.UUID, updates map[string]any) (response.RosterResponse, error) {
	if m.updateRosterFn != nil {
		return m.updateRosterFn(ctx, rosterID, ownerID, updates)
	}
	return response.RosterResponse{}, nil
}

func (m *mockRosterService) DeleteRoster(ctx context.Context, rosterID, ownerID uuid.UUID) error {
	if m.deleteRosterFn != nil {
		return m.deleteRosterFn(ctx, rosterID, ownerID)
	}
	return nil
}

func (m *mockRosterService) AddStudents(ctx context.Context, rosterID, ownerID uuid.UUID, studentIDs []uuid.UUID, note *string) (response.RosterResponse, error) {
	if m.addStudentsFn != nil {
		return m.addStudentsFn(ctx, rosterID, ownerID, studentIDs, note)
	}
	return response.RosterResponse{}, nil
}

func (m *mockRosterService) UpdateParticipantNote(ctx context.Context, rosterID, studentID, ownerID uuid.UUID, note *string) error {
	if m.updateParticipantNoteFn != nil {
		return m.updateParticipantNoteFn(ctx, rosterID, studentID, ownerID, note)
	}
	return nil
}

func (m *mockRosterService) RemoveStudent(ctx context.Context, rosterID, studentID, ownerID uuid.UUID) error {
	if m.removeStudentFn != nil {
		return m.removeStudentFn(ctx, rosterID, studentID, ownerID)
	}
	return nil
}

func setupRosterRouter(svc rosterService, user auth.JwtUser) *gin.Engine {
	return harness.SetupTestRouter(user, func(rg *gin.RouterGroup) {
		NewHandler(svc).RegisterRoutes(rg)
	})
}

func TestRosterHandler_GetAllRosters(t *testing.T) {
	testUser := auth.JwtUser{ID: uuid.New(), Email: "coach@example.com"}

	t.Run("Unauthorized", func(t *testing.T) {
		r := setupRosterRouter(&mockRosterService{}, auth.JwtUser{})
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodGet, "/api/v1/rosters", nil)
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusUnauthorized, w.Code)
	})

	t.Run("Success", func(t *testing.T) {
		expected := []response.RosterResponse{
			{ID: uuid.New(), Name: "Competition A", CountOfStudents: 3},
		}
		mockSvc := &mockRosterService{
			getAllRostersFn: func(ctx context.Context, ownerID uuid.UUID) ([]response.RosterResponse, error) {
				assert.Equal(t, testUser.ID, ownerID)
				return expected, nil
			},
		}

		r := setupRosterRouter(mockSvc, testUser)
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodGet, "/api/v1/rosters", nil)
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusOK, w.Code)
		var actual []response.RosterResponse
		err := json.Unmarshal(w.Body.Bytes(), &actual)
		require.NoError(t, err)
		assert.Equal(t, expected[0].ID, actual[0].ID)
		assert.Equal(t, "Competition A", actual[0].Name)
		assert.Equal(t, int64(3), actual[0].CountOfStudents)
	})
}

func TestRosterHandler_GetRosterByID(t *testing.T) {
	testUser := auth.JwtUser{ID: uuid.New(), Email: "coach@example.com"}
	rosterID := uuid.New()

	t.Run("Success", func(t *testing.T) {
		expected := response.RosterResponse{
			ID:              rosterID,
			Name:            "Competition A",
			CountOfStudents: 1,
			Students: []response.StudentResponse{
				{ID: uuid.New(), FullName: "John Doe"},
			},
		}
		mockSvc := &mockRosterService{
			getRosterByIDFn: func(ctx context.Context, rID, ownerID uuid.UUID) (response.RosterResponse, error) {
				assert.Equal(t, rosterID, rID)
				assert.Equal(t, testUser.ID, ownerID)
				return expected, nil
			},
		}

		r := setupRosterRouter(mockSvc, testUser)
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodGet, "/api/v1/rosters/"+rosterID.String(), nil)
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusOK, w.Code)
		var actual response.RosterResponse
		err := json.Unmarshal(w.Body.Bytes(), &actual)
		require.NoError(t, err)
		assert.Equal(t, rosterID, actual.ID)
		assert.Equal(t, "Competition A", actual.Name)
		assert.Len(t, actual.Students, 1)
	})

	t.Run("NotFound", func(t *testing.T) {
		mockSvc := &mockRosterService{
			getRosterByIDFn: func(ctx context.Context, rID, ownerID uuid.UUID) (response.RosterResponse, error) {
				return response.RosterResponse{}, pkgerrors.NewNotFound("Roster", rID, ownerID)
			},
		}

		r := setupRosterRouter(mockSvc, testUser)
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodGet, "/api/v1/rosters/"+rosterID.String(), nil)
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusNotFound, w.Code)
	})
}

func TestRosterHandler_CreateRoster(t *testing.T) {
	testUser := auth.JwtUser{ID: uuid.New(), Email: "coach@example.com"}

	t.Run("Success", func(t *testing.T) {
		now := time.Now().UTC()
		note := "Championship"
		reqBody := request.CreateRosterRequest{
			Name: "Competition A",
			Date: &now,
			Note: &note,
		}

		mockSvc := &mockRosterService{
			createRosterFn: func(ctx context.Context, req request.CreateRosterRequest, ownerID uuid.UUID) (response.RosterResponse, error) {
				assert.Equal(t, "Competition A", req.Name)
				assert.Equal(t, &note, req.Note)
				assert.Equal(t, testUser.ID, ownerID)
				return response.RosterResponse{
					ID:   uuid.New(),
					Name: req.Name,
					Date: req.Date,
					Note: req.Note,
				}, nil
			},
		}

		bodyBytes, _ := json.Marshal(reqBody)
		r := setupRosterRouter(mockSvc, testUser)
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodPost, "/api/v1/rosters", bytes.NewReader(bodyBytes))
		req.Header.Set("Content-Type", "application/json")
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusCreated, w.Code)
	})

	t.Run("Validation_BlankName", func(t *testing.T) {
		reqBody := map[string]any{
			"name": "   ",
		}
		bodyBytes, _ := json.Marshal(reqBody)
		r := setupRosterRouter(&mockRosterService{}, testUser)
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodPost, "/api/v1/rosters", bytes.NewReader(bodyBytes))
		req.Header.Set("Content-Type", "application/json")
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusBadRequest, w.Code)
	})
}

func TestRosterHandler_UpdateRoster(t *testing.T) {
	testUser := auth.JwtUser{ID: uuid.New(), Email: "coach@example.com"}
	rosterID := uuid.New()

	t.Run("Success", func(t *testing.T) {
		mockSvc := &mockRosterService{
			updateRosterFn: func(ctx context.Context, rID, ownerID uuid.UUID, updates map[string]any) (response.RosterResponse, error) {
				assert.Equal(t, rosterID, rID)
				assert.Equal(t, "Competition B", updates["name"])
				return response.RosterResponse{
					ID:   rID,
					Name: "Competition B",
				}, nil
			},
		}

		updates := map[string]any{"name": "Competition B"}
		bodyBytes, _ := json.Marshal(updates)
		r := setupRosterRouter(mockSvc, testUser)
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodPatch, "/api/v1/rosters/"+rosterID.String(), bytes.NewReader(bodyBytes))
		req.Header.Set("Content-Type", "application/json")
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusOK, w.Code)
	})
}

func TestRosterHandler_DeleteRoster(t *testing.T) {
	testUser := auth.JwtUser{ID: uuid.New(), Email: "coach@example.com"}
	rosterID := uuid.New()

	t.Run("Success", func(t *testing.T) {
		mockSvc := &mockRosterService{
			deleteRosterFn: func(ctx context.Context, rID, ownerID uuid.UUID) error {
				assert.Equal(t, rosterID, rID)
				return nil
			},
		}

		r := setupRosterRouter(mockSvc, testUser)
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodDelete, "/api/v1/rosters/"+rosterID.String(), nil)
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusNoContent, w.Code)
	})
}

func TestRosterHandler_AddAndRemoveStudents(t *testing.T) {
	testUser := auth.JwtUser{ID: uuid.New(), Email: "coach@example.com"}
	rosterID := uuid.New()
	studentID := uuid.New()

	t.Run("AddStudents_Success", func(t *testing.T) {
		mockSvc := &mockRosterService{
			addStudentsFn: func(ctx context.Context, rID, ownerID uuid.UUID, studentIDs []uuid.UUID, note *string) (response.RosterResponse, error) {
				assert.Equal(t, rosterID, rID)
				assert.Equal(t, []uuid.UUID{studentID}, studentIDs)
				return response.RosterResponse{
					ID:              rID,
					Name:            "Competition A",
					CountOfStudents: 1,
				}, nil
			},
		}

		reqBody := request.AddRosterStudentsRequest{
			StudentIds: []uuid.UUID{studentID},
		}
		bodyBytes, _ := json.Marshal(reqBody)
		r := setupRosterRouter(mockSvc, testUser)
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodPost, "/api/v1/rosters/"+rosterID.String()+"/students", bytes.NewReader(bodyBytes))
		req.Header.Set("Content-Type", "application/json")
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusOK, w.Code)
	})

	t.Run("RemoveStudent_Success", func(t *testing.T) {
		mockSvc := &mockRosterService{
			removeStudentFn: func(ctx context.Context, rID, sID, ownerID uuid.UUID) error {
				assert.Equal(t, rosterID, rID)
				assert.Equal(t, studentID, sID)
				return nil
			},
		}

		r := setupRosterRouter(mockSvc, testUser)
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodDelete, "/api/v1/rosters/"+rosterID.String()+"/students/"+studentID.String(), nil)
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusNoContent, w.Code)
	})

	t.Run("UpdateStudentNote_Success", func(t *testing.T) {
		noteVal := "new note"
		mockSvc := &mockRosterService{
			updateParticipantNoteFn: func(ctx context.Context, rID, sID, ownerID uuid.UUID, note *string) error {
				assert.Equal(t, rosterID, rID)
				assert.Equal(t, studentID, sID)
				assert.Equal(t, &noteVal, note)
				return nil
			},
		}

		reqBody := request.UpdateRosterStudentNoteRequest{
			Note: &noteVal,
		}
		bodyBytes, _ := json.Marshal(reqBody)
		r := setupRosterRouter(mockSvc, testUser)
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodPatch, "/api/v1/rosters/"+rosterID.String()+"/students/"+studentID.String(), bytes.NewReader(bodyBytes))
		req.Header.Set("Content-Type", "application/json")
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusNoContent, w.Code)
	})
}
