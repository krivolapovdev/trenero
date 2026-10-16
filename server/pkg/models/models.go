package models

import (
	"time"

	"github.com/google/uuid"
	"github.com/krivolapovdev/trenerio/pkg/types"
)

// @name UserResponse
type UserResponse struct {
	ID    uuid.UUID `json:"id" validate:"required" format:"uuid"`
	Email string    `json:"email" validate:"required"`
}

// @name OAuth2LoginRequest
type OAuth2LoginRequest struct {
	Token string `json:"token" binding:"required" validate:"required"`
}

// @name RefreshTokenRequest
type RefreshTokenRequest struct {
	RefreshToken string `json:"refreshToken" binding:"required" validate:"required"`
}

// @name JwtResponse
type JwtResponse struct {
	AccessToken  string `json:"accessToken" validate:"required"`
	RefreshToken string `json:"refreshToken" validate:"required"`
}

// @name LoginResponse
type LoginResponse struct {
	User      UserResponse `json:"user" validate:"required"`
	JwtTokens JwtResponse  `json:"jwtTokens" validate:"required"`
}

// @name GroupResponse
type GroupResponse struct {
	ID           uuid.UUID `json:"id" validate:"required" format:"uuid"`
	Name         string    `json:"name" validate:"required"`
	DefaultPrice *float64  `json:"defaultPrice,omitempty"`
	Note         *string   `json:"note,omitempty"`
	CreatedAt    time.Time `json:"createdAt" validate:"required" format:"date-time"`
}

// @name GroupStudentResponse
type GroupStudentResponse struct {
	ID        uuid.UUID `json:"id" validate:"required" format:"uuid"`
	GroupID   uuid.UUID `json:"groupId" validate:"required" format:"uuid"`
	StudentID uuid.UUID `json:"studentId" validate:"required" format:"uuid"`
}

// @name GroupSummaryResponse
type GroupSummaryResponse struct {
	ID              uuid.UUID `json:"id" validate:"required" format:"uuid"`
	Name            string    `json:"name" validate:"required"`
	DefaultPrice    *float64  `json:"defaultPrice,omitempty"`
	Note            *string   `json:"note,omitempty"`
	CreatedAt       time.Time `json:"createdAt" validate:"required" format:"date-time"`
	CountOfStudents int64     `json:"countOfStudents"`
}

// @name GroupStudentSummaryResponse
type GroupStudentSummaryResponse struct {
	ID        uuid.UUID             `json:"id" validate:"required" format:"uuid"`
	FullName  string                `json:"fullName" validate:"required"`
	Birthdate *types.Date           `json:"birthdate,omitempty" swaggertype:"string" format:"date"`
	Phone     *string               `json:"phone,omitempty"`
	Note      *string               `json:"note,omitempty"`
	CreatedAt time.Time             `json:"createdAt" validate:"required" format:"date-time"`
	Free      bool                  `json:"free" validate:"required"`
	Statuses  []types.StudentStatus `json:"statuses" validate:"required"`
}

// @name GroupReportStudentResponse
type GroupReportStudentResponse struct {
	StudentID    uuid.UUID `json:"studentId" validate:"required" format:"uuid"`
	FullName     string    `json:"fullName" validate:"required"`
	Paid         bool      `json:"paid" validate:"required"`
	PresentDays  []int     `json:"presentDays" validate:"required"`
	PresentCount int       `json:"presentCount" validate:"required"`
	LessonCount  int       `json:"lessonCount" validate:"required"`
}

// @name GroupReportResponse
type GroupReportResponse struct {
	GroupID      uuid.UUID                    `json:"groupId" validate:"required" format:"uuid"`
	GroupName    string                       `json:"groupName" validate:"required"`
	Year         int                          `json:"year" validate:"required"`
	Month        int                          `json:"month" validate:"required"`
	DayCount     int                          `json:"dayCount" validate:"required"`
	LessonDays   []int                        `json:"lessonDays" validate:"required"`
	Students     []GroupReportStudentResponse `json:"students" validate:"required"`
	TotalPresent int                          `json:"totalPresent" validate:"required"`
	TotalLessons int                          `json:"totalLessons" validate:"required"`
}

// @name CreateGroupRequest
type CreateGroupRequest struct {
	Name         string      `json:"name" validate:"required"`
	DefaultPrice *float64    `json:"defaultPrice"`
	Note         *string     `json:"note"`
	StudentIds   []uuid.UUID `json:"studentIds"`
}

// @name StudentResponse
type StudentResponse struct {
	ID        uuid.UUID   `json:"id" validate:"required" format:"uuid"`
	FullName  string      `json:"fullName" validate:"required"`
	Birthdate *types.Date `json:"birthdate,omitempty" swaggertype:"string" format:"date"`
	Phone     *string     `json:"phone,omitempty"`
	Note      *string     `json:"note,omitempty"`
	CreatedAt time.Time   `json:"createdAt" validate:"required" format:"date-time"`
	Free      bool        `json:"free" validate:"required"`
}

// @name StudentSummaryResponse
type StudentSummaryResponse struct {
	ID            uuid.UUID             `json:"id" validate:"required" format:"uuid"`
	FullName      string                `json:"fullName" validate:"required"`
	Birthdate     *types.Date           `json:"birthdate,omitempty" swaggertype:"string" format:"date"`
	Phone         *string               `json:"phone,omitempty"`
	Note          *string               `json:"note,omitempty"`
	CreatedAt     time.Time             `json:"createdAt" validate:"required" format:"date-time"`
	Free          bool                  `json:"free" validate:"required"`
	Statuses      []types.StudentStatus `json:"statuses" validate:"required"`
	StudentGroups []GroupResponse       `json:"studentGroups"`
}

// @name CreateStudentRequest
type CreateStudentRequest struct {
	FullName  string      `json:"fullName" validate:"required"`
	Birthdate *types.Date `json:"birthdate" swaggertype:"string" format:"date"`
	Phone     *string     `json:"phone"`
	Note      *string     `json:"note"`
	Free      bool        `json:"free" validate:"required"`
}

// @name CreateStudentPaymentRequest
type CreateStudentPaymentRequest struct {
	Amount    float64   `json:"amount" binding:"required" validate:"required"`
	Date      time.Time `json:"date" binding:"required" validate:"required" format:"date-time"`
	PaidUntil time.Time `json:"paidUntil" binding:"required" validate:"required" format:"date-time"`
}

// @name VisitResponse
type VisitResponse struct {
	ID        uuid.UUID         `json:"id" validate:"required" format:"uuid"`
	Status    types.VisitStatus `json:"status" validate:"required"`
	Type      types.VisitType   `json:"type" validate:"required"`
	LessonID  uuid.UUID         `json:"lessonId" validate:"required" format:"uuid"`
	StudentID uuid.UUID         `json:"studentId" validate:"required" format:"uuid"`
	CreatedAt time.Time         `json:"createdAt" validate:"required" format:"date-time"`
}

// @name StudentVisit
type StudentVisit struct {
	StudentID uuid.UUID         `json:"studentId" format:"uuid"`
	Status    types.VisitStatus `json:"status"`
	Type      types.VisitType   `json:"type"`
}

// @name LessonResponse
type LessonResponse struct {
	ID        uuid.UUID  `json:"id" validate:"required" format:"uuid"`
	Date      time.Time  `json:"date" validate:"required" format:"date-time"`
	CreatedAt time.Time  `json:"createdAt" validate:"required" format:"date-time"`
	GroupID   *uuid.UUID `json:"groupId,omitempty" format:"uuid"`
}

// @name VisitWithLessonResponse
type VisitWithLessonResponse struct {
	Visit  VisitResponse  `json:"visit" validate:"required"`
	Lesson LessonResponse `json:"lesson" validate:"required"`
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

// @name LessonDetailsResponse
type LessonDetailsResponse struct {
	ID            uuid.UUID         `json:"id" validate:"required" format:"uuid"`
	Date          time.Time         `json:"date" validate:"required" format:"date-time"`
	CreatedAt     time.Time         `json:"createdAt" validate:"required" format:"date-time"`
	GroupID       *uuid.UUID        `json:"groupId,omitempty" format:"uuid"`
	StudentVisits []VisitResponse   `json:"studentVisits" validate:"required"`
	Students      []StudentResponse `json:"students" validate:"required"`
}

// @name StudentPaymentDetailsResponse
type StudentPaymentDetailsResponse struct {
	DetailsType string    `json:"detailsType" validate:"required"`
	StudentID   uuid.UUID `json:"studentId" validate:"required" format:"uuid"`
	PaidUntil   time.Time `json:"paidUntil" validate:"required" format:"date-time"`
	StudentName *string   `json:"studentName,omitempty"`
}

// @name CreateStudentPaymentDetailsRequest
type CreateStudentPaymentDetailsRequest struct {
	DetailsType string     `json:"detailsType" validate:"required"`
	StudentID   uuid.UUID  `json:"studentId" validate:"required" format:"uuid"`
	PaidUntil   time.Time  `json:"paidUntil" validate:"required" format:"date-time"`
	PaidFrom    *time.Time `json:"paidFrom" format:"date-time"`
}

// @name CreateTransactionRequest
type CreateTransactionRequest struct {
	Amount         float64                             `json:"amount" validate:"required"`
	Date           time.Time                           `json:"date" validate:"required" format:"date-time"`
	Type           types.TransactionType               `json:"type" validate:"required"`
	PaymentDetails *CreateStudentPaymentDetailsRequest `json:"paymentDetails"`
}

// @name TransactionResponse
type TransactionResponse struct {
	ID             uuid.UUID                      `json:"id" validate:"required" format:"uuid"`
	Amount         float64                        `json:"amount" validate:"required"`
	Date           time.Time                      `json:"date" validate:"required" format:"date-time"`
	Type           types.TransactionType          `json:"type" validate:"required"`
	CreatedAt      time.Time                      `json:"createdAt" validate:"required" format:"date-time"`
	PaymentDetails *StudentPaymentDetailsResponse `json:"paymentDetails,omitempty"`
}

// @name SortObject
type SortObject struct {
	Empty    bool `json:"empty"`
	Sorted   bool `json:"sorted"`
	Unsorted bool `json:"unsorted"`
}

// @name PageableObject
type PageableObject struct {
	Offset     int64       `json:"offset"`
	PageNumber int         `json:"pageNumber"`
	PageSize   int         `json:"pageSize"`
	Paged      bool        `json:"paged"`
	Unpaged    bool        `json:"unpaged"`
	Sort       *SortObject `json:"sort,omitempty"`
}

// @name PageTransactionResponse
type PageTransactionResponse struct {
	TotalPages       int                   `json:"totalPages"`
	TotalElements    int64                 `json:"totalElements"`
	Size             int                   `json:"size"`
	Content          []TransactionResponse `json:"content"`
	Number           int                   `json:"number"`
	First            bool                  `json:"first"`
	Last             bool                  `json:"last"`
	NumberOfElements int                   `json:"numberOfElements"`
	Empty            bool                  `json:"empty"`
	Sort             *SortObject           `json:"sort,omitempty"`
	Pageable         *PageableObject       `json:"pageable,omitempty"`
}

// @name PaymentMetricResponse
type PaymentMetricResponse struct {
	Date  time.Time `json:"date" validate:"required" format:"date-time"`
	Total float64   `json:"total" validate:"required"`
}
