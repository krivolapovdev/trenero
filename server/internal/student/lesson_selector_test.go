package student

import (
	"github.com/krivolapovdev/trenerio/pkg/response"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/stretchr/testify/assert"
)

func TestFindLatestLesson(t *testing.T) {
	t.Run("EmptyMap_ReturnsNil", func(t *testing.T) {
		assert.Nil(t, findLatestLesson(nil))
		assert.Nil(t, findLatestLesson(map[uuid.UUID]response.LessonResponse{}))
	})

	t.Run("DifferentDates_ReturnsLatestDate", func(t *testing.T) {
		id1, id2 := uuid.New(), uuid.New()
		l1 := response.LessonResponse{ID: id1, Date: time.Date(2026, 1, 10, 0, 0, 0, 0, time.UTC)}
		l2 := response.LessonResponse{ID: id2, Date: time.Date(2026, 1, 20, 0, 0, 0, 0, time.UTC)}

		lessons := map[uuid.UUID]response.LessonResponse{
			id1: l1,
			id2: l2,
		}

		latest := findLatestLesson(lessons)
		assert.NotNil(t, latest)
		assert.Equal(t, id2, latest.ID)
	})

	t.Run("SameDateDifferentCreatedAt_ReturnsLatestCreatedAt", func(t *testing.T) {
		id1, id2 := uuid.New(), uuid.New()
		commonDate := time.Date(2026, 1, 10, 0, 0, 0, 0, time.UTC)
		l1 := response.LessonResponse{ID: id1, Date: commonDate, CreatedAt: time.Date(2026, 1, 1, 10, 0, 0, 0, time.UTC)}
		l2 := response.LessonResponse{ID: id2, Date: commonDate, CreatedAt: time.Date(2026, 1, 1, 12, 0, 0, 0, time.UTC)}

		lessons := map[uuid.UUID]response.LessonResponse{
			id1: l1,
			id2: l2,
		}

		latest := findLatestLesson(lessons)
		assert.NotNil(t, latest)
		assert.Equal(t, id2, latest.ID)
	})
}
