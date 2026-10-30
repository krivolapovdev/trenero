package group

import (
	"time"

	"github.com/google/uuid"
	"github.com/krivolapovdev/trenerio/internal/shared/types"
	"github.com/krivolapovdev/trenerio/internal/student"
)

// @name GroupStudentSummaryResponse
type GroupStudentSummaryResponse struct {
	ID        uuid.UUID               `json:"id" binding:"required" format:"uuid"`
	FullName  string                  `json:"fullName" binding:"required"`
	Birthdate *types.Date             `json:"birthdate,omitempty" swaggertype:"string" format:"date"`
	Phone     *string                 `json:"phone,omitempty"`
	Note      *string                 `json:"note,omitempty"`
	CreatedAt time.Time               `json:"createdAt" binding:"required" format:"date-time"`
	Free      bool                    `json:"free" binding:"required"`
	Statuses  []student.StudentStatus `json:"statuses" binding:"required"`
}

// @name GroupReportDayMarkResponse
type GroupReportDayMarkResponse struct {
	Day   int    `json:"day" binding:"required"`
	Marks []bool `json:"marks" binding:"required"`
}

// @name GroupReportStudentResponse
type GroupReportStudentResponse struct {
	StudentID    uuid.UUID                    `json:"studentId" binding:"required" format:"uuid"`
	FullName     string                       `json:"fullName" binding:"required"`
	Paid         bool                         `json:"paid" binding:"required"`
	PresentDays  []int                        `json:"presentDays" binding:"required"`
	DayMarks     []GroupReportDayMarkResponse `json:"dayMarks" binding:"required"`
	PresentCount int                          `json:"presentCount" binding:"required"`
	LessonCount  int                          `json:"lessonCount" binding:"required"`
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
