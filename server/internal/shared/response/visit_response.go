package response

import (
	"github.com/krivolapovdev/trenerio/internal/visit"
)

// @name VisitResponse
type VisitResponse = visit.VisitResponse

// @name VisitWithLessonResponse
type VisitWithLessonResponse struct {
	Visit  VisitResponse  `json:"visit" binding:"required"`
	Lesson LessonResponse `json:"lesson" binding:"required"`
}
