package lesson

import (
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/krivolapovdev/trenerio/internal/shared/response"
	"github.com/stretchr/testify/assert"
)

func TestFindLatestLesson(t *testing.T) {
	t.Run("EmptyMapReturnsNil", func(t *testing.T) {
		assert.Nil(t, FindLatestLesson(nil))
		assert.Nil(t, FindLatestLesson(map[uuid.UUID]response.LessonResponse{}))
	})

	t.Run("SingleLesson", func(t *testing.T) {
		id := uuid.New()
		now := time.Now()
		lessons := map[uuid.UUID]response.LessonResponse{
			id: {ID: id, Date: now, CreatedAt: now},
		}
		latest := FindLatestLesson(lessons)
		assert.NotNil(t, latest)
		assert.Equal(t, id, latest.ID)
	})

	t.Run("MultipleLessonsDifferentDates", func(t *testing.T) {
		idOld := uuid.New()
		idNew := uuid.New()
		now := time.Now()
		lessons := map[uuid.UUID]response.LessonResponse{
			idOld: {ID: idOld, Date: now.Add(-24 * time.Hour), CreatedAt: now},
			idNew: {ID: idNew, Date: now, CreatedAt: now},
		}
		latest := FindLatestLesson(lessons)
		assert.NotNil(t, latest)
		assert.Equal(t, idNew, latest.ID)
	})

	t.Run("TiesBrokenByCreatedAt", func(t *testing.T) {
		idOld := uuid.New()
		idNew := uuid.New()
		sameDate := time.Date(2025, 1, 1, 10, 0, 0, 0, time.UTC)
		lessons := map[uuid.UUID]response.LessonResponse{
			idOld: {ID: idOld, Date: sameDate, CreatedAt: sameDate},
			idNew: {ID: idNew, Date: sameDate, CreatedAt: sameDate.Add(time.Minute)},
		}
		latest := FindLatestLesson(lessons)
		assert.NotNil(t, latest)
		assert.Equal(t, idNew, latest.ID)
	})
}
