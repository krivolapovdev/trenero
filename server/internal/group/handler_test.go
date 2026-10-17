package group

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
	pkgerrors "github.com/krivolapovdev/trenerio/pkg/errors"
	"github.com/krivolapovdev/trenerio/pkg/models"
	"github.com/krivolapovdev/trenerio/pkg/security"
	"github.com/krivolapovdev/trenerio/pkg/testutil"
	"github.com/krivolapovdev/trenerio/pkg/types"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

type mockGroupService struct {
	getAllGroupsSummaryFn func(ctx context.Context, ownerID uuid.UUID) ([]models.GroupSummaryResponse, error)
	getGroupByIDFn        func(ctx context.Context, groupID, ownerID uuid.UUID) (models.GroupResponse, error)
	getGroupStudentsFn    func(ctx context.Context, groupID, ownerID uuid.UUID) ([]models.GroupStudentSummaryResponse, error)
	getGroupLessonsFn     func(ctx context.Context, groupID, ownerID uuid.UUID, from, to time.Time) ([]models.LessonResponse, error)
	getGroupReportFn      func(ctx context.Context, groupID, ownerID uuid.UUID, year, month int) (models.GroupReportResponse, error)
	createGroupFn         func(ctx context.Context, req models.CreateGroupRequest, ownerID uuid.UUID) (models.GroupResponse, error)
	updateGroupFn         func(ctx context.Context, groupID, ownerID uuid.UUID, updates map[string]any) (models.GroupResponse, error)
	deleteGroupFn         func(ctx context.Context, groupID, ownerID uuid.UUID) error
}

func (m *mockGroupService) GetAllGroupsSummary(ctx context.Context, ownerID uuid.UUID) ([]models.GroupSummaryResponse, error) {
	if m.getAllGroupsSummaryFn != nil {
		return m.getAllGroupsSummaryFn(ctx, ownerID)
	}
	return nil, nil
}

func (m *mockGroupService) GetGroupByID(ctx context.Context, groupID, ownerID uuid.UUID) (models.GroupResponse, error) {
	if m.getGroupByIDFn != nil {
		return m.getGroupByIDFn(ctx, groupID, ownerID)
	}
	return models.GroupResponse{}, nil
}

func (m *mockGroupService) GetGroupStudents(ctx context.Context, groupID, ownerID uuid.UUID) ([]models.GroupStudentSummaryResponse, error) {
	if m.getGroupStudentsFn != nil {
		return m.getGroupStudentsFn(ctx, groupID, ownerID)
	}
	return nil, nil
}

func (m *mockGroupService) GetGroupLessons(ctx context.Context, groupID, ownerID uuid.UUID, from, to time.Time) ([]models.LessonResponse, error) {
	if m.getGroupLessonsFn != nil {
		return m.getGroupLessonsFn(ctx, groupID, ownerID, from, to)
	}
	return nil, nil
}

func (m *mockGroupService) GetGroupReport(ctx context.Context, groupID, ownerID uuid.UUID, year, month int) (models.GroupReportResponse, error) {
	if m.getGroupReportFn != nil {
		return m.getGroupReportFn(ctx, groupID, ownerID, year, month)
	}
	return models.GroupReportResponse{}, nil
}

func (m *mockGroupService) GetGroupsByStudentIDs(ctx context.Context, studentIDs []uuid.UUID, ownerID uuid.UUID) (map[uuid.UUID][]models.GroupResponse, error) {
	return nil, nil
}

func (m *mockGroupService) SetStudentGroups(ctx context.Context, studentID, ownerID uuid.UUID, groupIDs []uuid.UUID) error {
	return nil
}

func (m *mockGroupService) CreateGroup(ctx context.Context, req models.CreateGroupRequest, ownerID uuid.UUID) (models.GroupResponse, error) {
	if m.createGroupFn != nil {
		return m.createGroupFn(ctx, req, ownerID)
	}
	return models.GroupResponse{}, nil
}

func (m *mockGroupService) UpdateGroup(ctx context.Context, groupID, ownerID uuid.UUID, updates map[string]any) (models.GroupResponse, error) {
	if m.updateGroupFn != nil {
		return m.updateGroupFn(ctx, groupID, ownerID, updates)
	}
	return models.GroupResponse{}, nil
}

func (m *mockGroupService) DeleteGroup(ctx context.Context, groupID, ownerID uuid.UUID) error {
	if m.deleteGroupFn != nil {
		return m.deleteGroupFn(ctx, groupID, ownerID)
	}
	return nil
}

func setupGroupRouter(svc Service, user security.JwtUser) *gin.Engine {
	return testutil.SetupTestRouter(user, func(rg *gin.RouterGroup) {
		NewHandler(svc).RegisterRoutes(rg)
	})
}

func TestGroupHandler_GetAllGroupsSummary(t *testing.T) {
	testUser := security.JwtUser{ID: uuid.New(), Email: "coach@example.com"}

	t.Run("Unauthorized", func(t *testing.T) {
		r := setupGroupRouter(&mockGroupService{}, security.JwtUser{})
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodGet, "/api/v1/groups", nil)
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusUnauthorized, w.Code)
	})

	t.Run("Success", func(t *testing.T) {
		expected := []models.GroupSummaryResponse{
			{ID: uuid.New(), Name: "Beginners", CountOfStudents: 10},
		}
		mockSvc := &mockGroupService{
			getAllGroupsSummaryFn: func(ctx context.Context, ownerID uuid.UUID) ([]models.GroupSummaryResponse, error) {
				assert.Equal(t, testUser.ID, ownerID)
				return expected, nil
			},
		}

		r := setupGroupRouter(mockSvc, testUser)
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodGet, "/api/v1/groups", nil)
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusOK, w.Code)
		var actual []models.GroupSummaryResponse
		err := json.Unmarshal(w.Body.Bytes(), &actual)
		require.NoError(t, err)
		assert.Len(t, actual, 1)
		assert.Equal(t, "Beginners", actual[0].Name)
	})

	t.Run("InternalServerError", func(t *testing.T) {
		mockSvc := &mockGroupService{
			getAllGroupsSummaryFn: func(ctx context.Context, ownerID uuid.UUID) ([]models.GroupSummaryResponse, error) {
				return nil, assert.AnError
			},
		}

		r := setupGroupRouter(mockSvc, testUser)
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodGet, "/api/v1/groups", nil)
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusInternalServerError, w.Code)
	})
}

func TestGroupHandler_GetGroupStudents(t *testing.T) {
	testUser := security.JwtUser{ID: uuid.New(), Email: "coach@example.com"}
	groupID := uuid.New()

	t.Run("InvalidGroupID", func(t *testing.T) {
		r := setupGroupRouter(&mockGroupService{}, testUser)
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodGet, "/api/v1/groups/not-a-uuid/students", nil)
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusBadRequest, w.Code)
	})

	t.Run("Success", func(t *testing.T) {
		mockSvc := &mockGroupService{
			getGroupStudentsFn: func(ctx context.Context, gID, ownerID uuid.UUID) ([]models.GroupStudentSummaryResponse, error) {
				assert.Equal(t, groupID, gID)
				assert.Equal(t, testUser.ID, ownerID)
				return []models.GroupStudentSummaryResponse{
					{ID: uuid.New(), FullName: "Student 1"},
				}, nil
			},
		}

		r := setupGroupRouter(mockSvc, testUser)
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodGet, "/api/v1/groups/"+groupID.String()+"/students", nil)
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusOK, w.Code)
	})

	t.Run("NotFound", func(t *testing.T) {
		mockSvc := &mockGroupService{
			getGroupStudentsFn: func(ctx context.Context, gID, ownerID uuid.UUID) ([]models.GroupStudentSummaryResponse, error) {
				return nil, pkgerrors.NewNotFound("Group", gID, ownerID)
			},
		}

		r := setupGroupRouter(mockSvc, testUser)
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodGet, "/api/v1/groups/"+groupID.String()+"/students", nil)
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusNotFound, w.Code)
	})

	t.Run("InternalServerError", func(t *testing.T) {
		mockSvc := &mockGroupService{
			getGroupStudentsFn: func(ctx context.Context, gID, ownerID uuid.UUID) ([]models.GroupStudentSummaryResponse, error) {
				return nil, assert.AnError
			},
		}

		r := setupGroupRouter(mockSvc, testUser)
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodGet, "/api/v1/groups/"+groupID.String()+"/students", nil)
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusInternalServerError, w.Code)
	})
}

func TestGroupHandler_GetGroupLessons(t *testing.T) {
	testUser := security.JwtUser{ID: uuid.New(), Email: "coach@example.com"}
	groupID := uuid.New()

	t.Run("MissingQueryParams", func(t *testing.T) {
		r := setupGroupRouter(&mockGroupService{}, testUser)
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodGet, "/api/v1/groups/"+groupID.String()+"/lessons", nil)
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusBadRequest, w.Code)
	})

	t.Run("InvalidDateFormat", func(t *testing.T) {
		r := setupGroupRouter(&mockGroupService{}, testUser)
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodGet, "/api/v1/groups/"+groupID.String()+"/lessons?from=bad&to=bad", nil)
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusBadRequest, w.Code)
	})

	t.Run("Success", func(t *testing.T) {
		from := time.Date(2026, 1, 1, 0, 0, 0, 0, time.UTC)
		to := time.Date(2026, 1, 31, 23, 59, 59, 0, time.UTC)

		mockSvc := &mockGroupService{
			getGroupLessonsFn: func(ctx context.Context, gID, ownerID uuid.UUID, f, toDate time.Time) ([]models.LessonResponse, error) {
				assert.Equal(t, groupID, gID)
				assert.True(t, from.Equal(f))
				assert.True(t, to.Equal(toDate))
				return []models.LessonResponse{{ID: uuid.New()}}, nil
			},
		}

		r := setupGroupRouter(mockSvc, testUser)
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodGet, "/api/v1/groups/"+groupID.String()+"/lessons?from="+from.Format(time.RFC3339)+"&to="+to.Format(time.RFC3339), nil)
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusOK, w.Code)
	})

	t.Run("InternalServerError", func(t *testing.T) {
		from := time.Date(2026, 1, 1, 0, 0, 0, 0, time.UTC)
		to := time.Date(2026, 1, 31, 23, 59, 59, 0, time.UTC)
		mockSvc := &mockGroupService{
			getGroupLessonsFn: func(ctx context.Context, gID, ownerID uuid.UUID, f, toDate time.Time) ([]models.LessonResponse, error) {
				return nil, assert.AnError
			},
		}
		r := setupGroupRouter(mockSvc, testUser)
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodGet, "/api/v1/groups/"+groupID.String()+"/lessons?from="+from.Format(time.RFC3339)+"&to="+to.Format(time.RFC3339), nil)
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusInternalServerError, w.Code)
	})
}

func TestGroupHandler_GetGroupReport(t *testing.T) {
	testUser := security.JwtUser{ID: uuid.New(), Email: "coach@example.com"}
	groupID := uuid.New()

	t.Run("MissingParams", func(t *testing.T) {
		r := setupGroupRouter(&mockGroupService{}, testUser)
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodGet, "/api/v1/groups/"+groupID.String()+"/report", nil)
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusBadRequest, w.Code)
	})

	t.Run("InvalidMonthRange", func(t *testing.T) {
		r := setupGroupRouter(&mockGroupService{}, testUser)
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodGet, "/api/v1/groups/"+groupID.String()+"/report?year=2026&month=13", nil)
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusBadRequest, w.Code)
	})

	t.Run("InvalidYearOrMonthValues", func(t *testing.T) {
		r := setupGroupRouter(&mockGroupService{}, testUser)

		testCases := []string{
			"/api/v1/groups/" + groupID.String() + "/report?year=0&month=5",
			"/api/v1/groups/" + groupID.String() + "/report?year=2026&month=0",
			"/api/v1/groups/" + groupID.String() + "/report?year=abc&month=5",
			"/api/v1/groups/" + groupID.String() + "/report?year=2026&month=xyz",
		}

		for _, url := range testCases {
			w := httptest.NewRecorder()
			req := httptest.NewRequest(http.MethodGet, url, nil)
			r.ServeHTTP(w, req)
			assert.Equal(t, http.StatusBadRequest, w.Code)
		}
	})

	t.Run("Success", func(t *testing.T) {
		mockSvc := &mockGroupService{
			getGroupReportFn: func(ctx context.Context, gID, ownerID uuid.UUID, year, month int) (models.GroupReportResponse, error) {
				assert.Equal(t, 2026, year)
				assert.Equal(t, 10, month)
				return models.GroupReportResponse{Year: year, Month: month}, nil
			},
		}

		r := setupGroupRouter(mockSvc, testUser)
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodGet, "/api/v1/groups/"+groupID.String()+"/report?year=2026&month=10", nil)
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusOK, w.Code)
	})

	t.Run("InternalServerError", func(t *testing.T) {
		mockSvc := &mockGroupService{
			getGroupReportFn: func(ctx context.Context, gID, ownerID uuid.UUID, year, month int) (models.GroupReportResponse, error) {
				return models.GroupReportResponse{}, assert.AnError
			},
		}

		r := setupGroupRouter(mockSvc, testUser)
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodGet, "/api/v1/groups/"+groupID.String()+"/report?year=2026&month=10", nil)
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusInternalServerError, w.Code)
	})
}

func TestGroupHandler_CreateGroup(t *testing.T) {
	testUser := security.JwtUser{ID: uuid.New(), Email: "coach@example.com"}

	t.Run("InvalidJSON", func(t *testing.T) {
		r := setupGroupRouter(&mockGroupService{}, testUser)
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodPost, "/api/v1/groups", bytes.NewBufferString(`{invalid`))
		req.Header.Set("Content-Type", "application/json")
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusBadRequest, w.Code)
	})

	t.Run("Success", func(t *testing.T) {
		expectedID := uuid.New()
		mockSvc := &mockGroupService{
			createGroupFn: func(ctx context.Context, req models.CreateGroupRequest, ownerID uuid.UUID) (models.GroupResponse, error) {
				assert.Equal(t, "Advanced", req.Name)
				return models.GroupResponse{ID: expectedID, Name: req.Name}, nil
			},
		}

		r := setupGroupRouter(mockSvc, testUser)
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodPost, "/api/v1/groups", bytes.NewBufferString(`{"name":"Advanced"}`))
		req.Header.Set("Content-Type", "application/json")
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusCreated, w.Code)
	})

	t.Run("ConflictError", func(t *testing.T) {
		mockSvc := &mockGroupService{
			createGroupFn: func(ctx context.Context, req models.CreateGroupRequest, ownerID uuid.UUID) (models.GroupResponse, error) {
				return models.GroupResponse{}, pkgerrors.NewConflict(types.ErrGroupNameNotUnique, "Group already exists")
			},
		}

		r := setupGroupRouter(mockSvc, testUser)
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodPost, "/api/v1/groups", bytes.NewBufferString(`{"name":"Duplicate"}`))
		req.Header.Set("Content-Type", "application/json")
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusConflict, w.Code)
	})

	t.Run("BlankName", func(t *testing.T) {
		r := setupGroupRouter(&mockGroupService{}, testUser)
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodPost, "/api/v1/groups", bytes.NewBufferString(`{"name":"   "}`))
		req.Header.Set("Content-Type", "application/json")
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusBadRequest, w.Code)
	})

	t.Run("NonPositiveDefaultPrice", func(t *testing.T) {
		r := setupGroupRouter(&mockGroupService{}, testUser)
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodPost, "/api/v1/groups", bytes.NewBufferString(`{"name":"Advanced","defaultPrice":0}`))
		req.Header.Set("Content-Type", "application/json")
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusBadRequest, w.Code)
	})

	t.Run("NegativeDefaultPrice", func(t *testing.T) {
		r := setupGroupRouter(&mockGroupService{}, testUser)
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodPost, "/api/v1/groups", bytes.NewBufferString(`{"name":"Advanced","defaultPrice":-10}`))
		req.Header.Set("Content-Type", "application/json")
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusBadRequest, w.Code)
	})

	t.Run("NullDefaultPrice", func(t *testing.T) {
		mockSvc := &mockGroupService{
			createGroupFn: func(ctx context.Context, req models.CreateGroupRequest, ownerID uuid.UUID) (models.GroupResponse, error) {
				assert.Nil(t, req.DefaultPrice)
				return models.GroupResponse{ID: uuid.New(), Name: req.Name}, nil
			},
		}
		r := setupGroupRouter(mockSvc, testUser)
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodPost, "/api/v1/groups", bytes.NewBufferString(`{"name":"Advanced","defaultPrice":null}`))
		req.Header.Set("Content-Type", "application/json")
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusCreated, w.Code)
	})

	t.Run("PositiveDefaultPrice", func(t *testing.T) {
		mockSvc := &mockGroupService{
			createGroupFn: func(ctx context.Context, req models.CreateGroupRequest, ownerID uuid.UUID) (models.GroupResponse, error) {
				require.NotNil(t, req.DefaultPrice)
				assert.Equal(t, 150.0, *req.DefaultPrice)
				return models.GroupResponse{ID: uuid.New(), Name: req.Name, DefaultPrice: req.DefaultPrice}, nil
			},
		}
		r := setupGroupRouter(mockSvc, testUser)
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodPost, "/api/v1/groups", bytes.NewBufferString(`{"name":"Advanced","defaultPrice":150.0}`))
		req.Header.Set("Content-Type", "application/json")
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusCreated, w.Code)
	})

	t.Run("TrimmedData", func(t *testing.T) {
		expectedID := uuid.New()
		mockSvc := &mockGroupService{
			createGroupFn: func(ctx context.Context, req models.CreateGroupRequest, ownerID uuid.UUID) (models.GroupResponse, error) {
				assert.Equal(t, "Advanced", req.Name)
				require.NotNil(t, req.Note)
				assert.Equal(t, "note text", *req.Note)
				return models.GroupResponse{ID: expectedID, Name: req.Name, Note: req.Note}, nil
			},
		}

		r := setupGroupRouter(mockSvc, testUser)
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodPost, "/api/v1/groups", bytes.NewBufferString(`{"name":"  Advanced  ","note":"  note text  "}`))
		req.Header.Set("Content-Type", "application/json")
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusCreated, w.Code)
	})

	t.Run("InternalServerError", func(t *testing.T) {
		mockSvc := &mockGroupService{
			createGroupFn: func(ctx context.Context, req models.CreateGroupRequest, ownerID uuid.UUID) (models.GroupResponse, error) {
				return models.GroupResponse{}, assert.AnError
			},
		}

		r := setupGroupRouter(mockSvc, testUser)
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodPost, "/api/v1/groups", bytes.NewBufferString(`{"name":"Crash"}`))
		req.Header.Set("Content-Type", "application/json")
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusInternalServerError, w.Code)
	})
}

func TestGroupHandler_UpdateGroup(t *testing.T) {
	testUser := security.JwtUser{ID: uuid.New(), Email: "coach@example.com"}
	groupID := uuid.New()

	t.Run("InvalidGroupID", func(t *testing.T) {
		r := setupGroupRouter(&mockGroupService{}, testUser)
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodPatch, "/api/v1/groups/not-uuid", bytes.NewBufferString(`{"name":"New"}`))
		req.Header.Set("Content-Type", "application/json")
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusBadRequest, w.Code)
	})

	t.Run("InvalidJSON", func(t *testing.T) {
		r := setupGroupRouter(&mockGroupService{}, testUser)
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodPatch, "/api/v1/groups/"+groupID.String(), bytes.NewBufferString(`{invalid`))
		req.Header.Set("Content-Type", "application/json")
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusBadRequest, w.Code)
	})

	t.Run("Success", func(t *testing.T) {
		mockSvc := &mockGroupService{
			updateGroupFn: func(ctx context.Context, gID, ownerID uuid.UUID, updates map[string]any) (models.GroupResponse, error) {
				assert.Equal(t, groupID, gID)
				assert.Equal(t, "Updated Name", updates["name"])
				return models.GroupResponse{ID: groupID, Name: "Updated Name"}, nil
			},
		}

		r := setupGroupRouter(mockSvc, testUser)
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodPatch, "/api/v1/groups/"+groupID.String(), bytes.NewBufferString(`{"name":"Updated Name"}`))
		req.Header.Set("Content-Type", "application/json")
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusOK, w.Code)
	})

	t.Run("BlankName", func(t *testing.T) {
		r := setupGroupRouter(&mockGroupService{}, testUser)
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodPatch, "/api/v1/groups/"+groupID.String(), bytes.NewBufferString(`{"name":"   "}`))
		req.Header.Set("Content-Type", "application/json")
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusBadRequest, w.Code)
	})

	t.Run("TrimmedData", func(t *testing.T) {
		mockSvc := &mockGroupService{
			updateGroupFn: func(ctx context.Context, gID, ownerID uuid.UUID, updates map[string]any) (models.GroupResponse, error) {
				assert.Equal(t, groupID, gID)
				assert.Equal(t, "Updated Name", updates["name"])
				assert.Equal(t, "new note", updates["note"])
				return models.GroupResponse{ID: groupID, Name: "Updated Name"}, nil
			},
		}

		r := setupGroupRouter(mockSvc, testUser)
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodPatch, "/api/v1/groups/"+groupID.String(), bytes.NewBufferString(`{"name":"  Updated Name  ","note":"  new note  "}`))
		req.Header.Set("Content-Type", "application/json")
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusOK, w.Code)
	})

	t.Run("InternalServerError", func(t *testing.T) {
		mockSvc := &mockGroupService{
			updateGroupFn: func(ctx context.Context, gID, ownerID uuid.UUID, updates map[string]any) (models.GroupResponse, error) {
				return models.GroupResponse{}, assert.AnError
			},
		}

		r := setupGroupRouter(mockSvc, testUser)
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodPatch, "/api/v1/groups/"+groupID.String(), bytes.NewBufferString(`{"name":"Crash"}`))
		req.Header.Set("Content-Type", "application/json")
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusInternalServerError, w.Code)
	})
}

func TestGroupHandler_DeleteGroup(t *testing.T) {
	testUser := security.JwtUser{ID: uuid.New(), Email: "coach@example.com"}
	groupID := uuid.New()

	t.Run("InvalidGroupID", func(t *testing.T) {
		r := setupGroupRouter(&mockGroupService{}, testUser)
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodDelete, "/api/v1/groups/bad-uuid", nil)
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusBadRequest, w.Code)
	})

	t.Run("Success", func(t *testing.T) {
		called := false
		mockSvc := &mockGroupService{
			deleteGroupFn: func(ctx context.Context, gID, ownerID uuid.UUID) error {
				assert.Equal(t, groupID, gID)
				called = true
				return nil
			},
		}

		r := setupGroupRouter(mockSvc, testUser)
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodDelete, "/api/v1/groups/"+groupID.String(), nil)
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusNoContent, w.Code)
		assert.True(t, called)
	})

	t.Run("NotFound", func(t *testing.T) {
		mockSvc := &mockGroupService{
			deleteGroupFn: func(ctx context.Context, gID, ownerID uuid.UUID) error {
				return pkgerrors.NewNotFound("Group", groupID, ownerID)
			},
		}

		r := setupGroupRouter(mockSvc, testUser)
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodDelete, "/api/v1/groups/"+groupID.String(), nil)
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusNotFound, w.Code)
	})

	t.Run("InternalServerError", func(t *testing.T) {
		mockSvc := &mockGroupService{
			deleteGroupFn: func(ctx context.Context, gID, ownerID uuid.UUID) error {
				return assert.AnError
			},
		}

		r := setupGroupRouter(mockSvc, testUser)
		w := httptest.NewRecorder()
		req := httptest.NewRequest(http.MethodDelete, "/api/v1/groups/"+groupID.String(), nil)
		r.ServeHTTP(w, req)

		assert.Equal(t, http.StatusInternalServerError, w.Code)
	})
}
