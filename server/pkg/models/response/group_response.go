package response

import (
	"time"

	"github.com/google/uuid"
	"github.com/krivolapovdev/trenerio/pkg/types"
)

// @name GroupResponse
type GroupResponse struct {
	ID           uuid.UUID `json:"id" format:"uuid"`
	Name         string    `json:"name"`
	DefaultPrice *float64  `json:"defaultPrice,omitempty"`
	Note         *string   `json:"note,omitempty"`
	CreatedAt    time.Time `json:"createdAt" format:"date-time"`
}

// @name GroupStudentResponse
type GroupStudentResponse struct {
	ID        uuid.UUID `json:"id" format:"uuid"`
	GroupID   uuid.UUID `json:"groupId" format:"uuid"`
	StudentID uuid.UUID `json:"studentId" format:"uuid"`
}

// @name GroupSummaryResponse
type GroupSummaryResponse struct {
	ID              uuid.UUID `json:"id" format:"uuid"`
	Name            string    `json:"name"`
	DefaultPrice    *float64  `json:"defaultPrice,omitempty"`
	Note            *string   `json:"note,omitempty"`
	CreatedAt       time.Time `json:"createdAt" format:"date-time"`
	CountOfStudents int64     `json:"countOfStudents"`
}

// @name GroupStudentSummaryResponse
type GroupStudentSummaryResponse struct {
	ID        uuid.UUID             `json:"id" format:"uuid"`
	FullName  string                `json:"fullName"`
	Birthdate *types.Date           `json:"birthdate,omitempty" swaggertype:"string" format:"date"`
	Phone     *string               `json:"phone,omitempty"`
	Note      *string               `json:"note,omitempty"`
	CreatedAt time.Time             `json:"createdAt" format:"date-time"`
	Free      bool                  `json:"free"`
	Statuses  []types.StudentStatus `json:"statuses"`
}

// @name GroupReportStudentResponse
type GroupReportStudentResponse struct {
	StudentID    uuid.UUID `json:"studentId" format:"uuid"`
	FullName     string    `json:"fullName"`
	Paid         bool      `json:"paid"`
	PresentDays  []int     `json:"presentDays"`
	PresentCount int       `json:"presentCount"`
	LessonCount  int       `json:"lessonCount"`
}

// @name GroupReportResponse
type GroupReportResponse struct {
	GroupID      uuid.UUID                    `json:"groupId" format:"uuid"`
	GroupName    string                       `json:"groupName"`
	Year         int                          `json:"year"`
	Month        int                          `json:"month"`
	DayCount     int                          `json:"dayCount"`
	LessonDays   []int                        `json:"lessonDays"`
	Students     []GroupReportStudentResponse `json:"students"`
	TotalPresent int                          `json:"totalPresent"`
	TotalLessons int                          `json:"totalLessons"`
}
