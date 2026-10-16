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
