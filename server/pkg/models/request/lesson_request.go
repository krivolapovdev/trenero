package request

import (
	"time"

	"github.com/google/uuid"
	"github.com/krivolapovdev/trenerio/pkg/types"
)

// @name StudentVisit
type StudentVisit struct {
	StudentID uuid.UUID         `json:"studentId" format:"uuid"`
	Status    types.VisitStatus `json:"status"`
	Type      types.VisitType   `json:"type"`
}

// @name CreateLessonRequest
type CreateLessonRequest struct {
	GroupID  *uuid.UUID     `json:"groupId" format:"uuid"`
	Date     time.Time      `json:"date" binding:"required" validate:"required" format:"date-time"`
	Students []StudentVisit `json:"students"`
}

// @name UpdateLessonRequest
type UpdateLessonRequest struct {
	Date     *time.Time     `json:"date" format:"date-time"`
	Students []StudentVisit `json:"students"`
}
