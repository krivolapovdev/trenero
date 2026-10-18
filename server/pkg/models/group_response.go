package models

import (
	"time"

	"github.com/google/uuid"
	"github.com/krivolapovdev/trenerio/pkg/types"
)

// @name GroupResponse
type GroupResponse struct {
	ID           uuid.UUID `json:"id" binding:"required" format:"uuid"`
	Name         string    `json:"name" binding:"required"`
	DefaultPrice *float64  `json:"defaultPrice,omitempty"`
	Note         *string   `json:"note,omitempty"`
	CreatedAt    time.Time `json:"createdAt" binding:"required" format:"date-time"`
}

// @name GroupStudentResponse
type GroupStudentResponse struct {
	ID        uuid.UUID `json:"id" format:"uuid"`
	GroupID   uuid.UUID `json:"groupId" format:"uuid"`
	StudentID uuid.UUID `json:"studentId" format:"uuid"`
}

// @name GroupSummaryResponse
type GroupSummaryResponse struct {
	ID              uuid.UUID `json:"id" binding:"required" format:"uuid"`
	Name            string    `json:"name" binding:"required"`
	DefaultPrice    *float64  `json:"defaultPrice,omitempty"`
	Note            *string   `json:"note,omitempty"`
	CreatedAt       time.Time `json:"createdAt" binding:"required" format:"date-time"`
	CountOfStudents int64     `json:"countOfStudents"`
}

// @name GroupStudentSummaryResponse
type GroupStudentSummaryResponse struct {
	ID        uuid.UUID             `json:"id" binding:"required" format:"uuid"`
	FullName  string                `json:"fullName" binding:"required"`
	Birthdate *types.Date           `json:"birthdate,omitempty" swaggertype:"string" format:"date"`
	Phone     *string               `json:"phone,omitempty"`
	Note      *string               `json:"note,omitempty"`
	CreatedAt time.Time             `json:"createdAt" binding:"required" format:"date-time"`
	Free      bool                  `json:"free" binding:"required"`
	Statuses  []types.StudentStatus `json:"statuses" binding:"required"`
}

// @name GroupReportStudentResponse
type GroupReportStudentResponse struct {
	StudentID    uuid.UUID `json:"studentId" binding:"required" format:"uuid"`
	FullName     string    `json:"fullName" binding:"required"`
	Paid         bool      `json:"paid" binding:"required"`
	PresentDays  []int     `json:"presentDays" binding:"required"`
	PresentCount int       `json:"presentCount" binding:"required"`
	LessonCount  int       `json:"lessonCount" binding:"required"`
}

// @name GroupReportResponse
type GroupReportResponse struct {
	GroupID      uuid.UUID                    `json:"groupId" binding:"required" format:"uuid"`
	GroupName    string                       `json:"groupName" binding:"required"`
	Year         int                          `json:"year" binding:"required"`
	Month        int                          `json:"month" binding:"required"`
	DayCount     int                          `json:"dayCount" binding:"required"`
	LessonDays   []int                        `json:"lessonDays" binding:"required"`
	Students     []GroupReportStudentResponse `json:"students" binding:"required"`
	TotalPresent int                          `json:"totalPresent" binding:"required"`
	TotalLessons int                          `json:"totalLessons" binding:"required"`
}
