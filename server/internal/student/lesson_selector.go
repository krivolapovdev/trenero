package student

import (
	"github.com/google/uuid"
	"github.com/krivolapovdev/trenerio/pkg/models"
)

// findLatestLesson finds the most recent lesson in the map ordered by Date descending,
// breaking ties by CreatedAt descending. If the map is empty, it returns nil.
func findLatestLesson(lessons map[uuid.UUID]models.LessonResponse) *models.LessonResponse {
	var latest *models.LessonResponse
	for _, l := range lessons {
		if latest == nil || isLessonAfter(l, *latest) {
			cur := l
			latest = &cur
		}
	}
	return latest
}

// isLessonAfter returns true if lesson a occurred after lesson b,
// comparing by Date first and tie-breaking by CreatedAt.
func isLessonAfter(a, b models.LessonResponse) bool {
	if a.Date.After(b.Date) {
		return true
	}
	return a.Date.Equal(b.Date) && a.CreatedAt.After(b.CreatedAt)
}
