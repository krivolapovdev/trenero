package lesson

import (
	"github.com/google/uuid"
	"github.com/krivolapovdev/trenerio/internal/db"
	"github.com/krivolapovdev/trenerio/internal/shared/response"
)

func toLessonResponse(l db.LessonsModuleLesson) response.LessonResponse {
	var groupID *uuid.UUID
	if l.GroupID.Valid {
		groupID = &l.GroupID.UUID
	}
	return response.LessonResponse{
		ID:        l.ID,
		Date:      l.Date,
		CreatedAt: l.CreatedAt,
		GroupID:   groupID,
	}
}
