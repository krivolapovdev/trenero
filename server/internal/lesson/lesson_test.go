package lesson

import (
	"context"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/krivolapovdev/trenerio/internal/db"
	"github.com/krivolapovdev/trenerio/pkg/models"
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

func TestLessonService_DateValidation(t *testing.T) {
	svc := NewService(nil, nil, nil, nil, nil, nil, nil)
	ctx := context.Background()
	ownerID := uuid.New()

	t.Run("CreateLesson_FutureDate", func(t *testing.T) {
		futureDate := time.Now().UTC().Add(24 * time.Hour)
		_, err := svc.CreateLesson(ctx, models.CreateLessonRequest{
			Date: futureDate,
		}, ownerID)
		assert.Error(t, err)
		assert.Contains(t, err.Error(), "date cannot be in the future")
	})

	t.Run("UpdateLesson_FutureDate", func(t *testing.T) {
		futureDate := time.Now().UTC().Add(24 * time.Hour)
		_, err := svc.UpdateLesson(ctx, uuid.New(), ownerID, models.UpdateLessonRequest{
			Date: &futureDate,
		})
		assert.Error(t, err)
		assert.Contains(t, err.Error(), "date cannot be in the future")
	})
}
