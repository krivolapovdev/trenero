package request

import (
	"time"

	"github.com/google/uuid"
	"github.com/krivolapovdev/trenerio/internal/visit"
)

// @name StudentVisit
type StudentVisit = visit.StudentVisit

// @name CreateLessonRequest
type CreateLessonRequest struct {
	GroupID  *uuid.UUID     `json:"groupId" format:"uuid"`
	Date     time.Time      `json:"date" binding:"required" format:"date-time"`
	Students []StudentVisit `json:"students"`
}

// @name UpdateLessonRequest
type UpdateLessonRequest struct {
	Date     *time.Time     `json:"date" format:"date-time"`
	Students []StudentVisit `json:"students"`
}
