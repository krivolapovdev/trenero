package lesson

import (
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/krivolapovdev/trenerio/internal/db"
	"github.com/stretchr/testify/assert"
)

func TestToLessonResponse(t *testing.T) {
	lessonID := uuid.New()
	groupID := uuid.New()
	now := time.Now()

	// With Group ID
	dbLessonWithGroup := db.LessonsModuleLesson{
		ID:        lessonID,
		Date:      now,
		CreatedAt: now,
		GroupID:   uuid.NullUUID{UUID: groupID, Valid: true},
	}
	respWithGroup := toLessonResponse(dbLessonWithGroup)
	assert.Equal(t, lessonID, respWithGroup.ID)
	assert.Equal(t, now, respWithGroup.Date)
	assert.NotNil(t, respWithGroup.GroupID)
	assert.Equal(t, groupID, *respWithGroup.GroupID)

	// Without Group ID
	dbLessonWithoutGroup := db.LessonsModuleLesson{
		ID:        lessonID,
		Date:      now,
		CreatedAt: now,
		GroupID:   uuid.NullUUID{Valid: false},
	}
	respWithoutGroup := toLessonResponse(dbLessonWithoutGroup)
	assert.Equal(t, lessonID, respWithoutGroup.ID)
	assert.Nil(t, respWithoutGroup.GroupID)
}
