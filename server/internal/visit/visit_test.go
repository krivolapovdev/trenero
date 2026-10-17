package visit

import (
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/krivolapovdev/trenerio/internal/db"
	"github.com/krivolapovdev/trenerio/pkg/types"
	"github.com/stretchr/testify/assert"
)

func TestToVisitResponse(t *testing.T) {
	visitID := uuid.New()
	lessonID := uuid.New()
	studentID := uuid.New()
	now := time.Now()

	dbVisit := db.VisitsModuleVisit{
		ID:        visitID,
		Status:    db.VisitsModuleVisitStatusPRESENT,
		Type:      db.VisitsModuleVisitTypeREGULAR,
		LessonID:  lessonID,
		StudentID: studentID,
		CreatedAt: now,
	}

	resp := toVisitResponse(dbVisit)
	assert.Equal(t, visitID, resp.ID)
	assert.Equal(t, types.VisitStatusPresent, resp.Status)
	assert.Equal(t, types.VisitTypeRegular, resp.Type)
	assert.Equal(t, lessonID, resp.LessonID)
	assert.Equal(t, studentID, resp.StudentID)
	assert.Equal(t, now, resp.CreatedAt)
}

func TestToVisitResponse_Variants(t *testing.T) {
	testCases := []struct {
		name       string
		dbStatus   db.VisitsModuleVisitStatus
		dbType     db.VisitsModuleVisitType
		wantStatus types.VisitStatus
		wantType   types.VisitType
	}{
		{
			name:       "Absent",
			dbStatus:   db.VisitsModuleVisitStatusABSENT,
			dbType:     db.VisitsModuleVisitTypeREGULAR,
			wantStatus: types.VisitStatusAbsent,
			wantType:   types.VisitTypeRegular,
		},
		{
			name:       "Excused",
			dbStatus:   db.VisitsModuleVisitStatusEXCUSED,
			dbType:     db.VisitsModuleVisitTypeREGULAR,
			wantStatus: types.VisitStatusExcused,
			wantType:   types.VisitTypeRegular,
		},
		{
			name:       "Free",
			dbStatus:   db.VisitsModuleVisitStatusPRESENT,
			dbType:     db.VisitsModuleVisitTypeFREE,
			wantStatus: types.VisitStatusPresent,
			wantType:   types.VisitTypeFree,
		},
	}

	for _, tc := range testCases {
		t.Run(tc.name, func(t *testing.T) {
			v := db.VisitsModuleVisit{
				ID:     uuid.New(),
				Status: tc.dbStatus,
				Type:   tc.dbType,
			}
			resp := toVisitResponse(v)
			assert.Equal(t, tc.wantStatus, resp.Status)
			assert.Equal(t, tc.wantType, resp.Type)
		})
	}
}

func TestVisitService_NewConstructors(t *testing.T) {
	s1 := NewService(nil, nil)
	assert.NotNil(t, s1)

	s2 := NewVisitService(nil, nil)
	assert.NotNil(t, s2)
}

func TestVisitService_EmptyIDQueries(t *testing.T) {
	svc := NewService(nil, nil)
	ownerID := uuid.New()

	t.Run("GetVisitsByLessonIDs_Empty", func(t *testing.T) {
		res, err := svc.GetVisitsByLessonIDs(t.Context(), []uuid.UUID{}, ownerID)
		assert.NoError(t, err)
		assert.Empty(t, res)
	})

	t.Run("GetVisitsByStudentIDs_Empty", func(t *testing.T) {
		res, err := svc.GetVisitsByStudentIDs(t.Context(), []uuid.UUID{}, ownerID)
		assert.NoError(t, err)
		assert.Empty(t, res)
	})
}
