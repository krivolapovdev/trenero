package models

import (
	"time"

	"github.com/google/uuid"
	"github.com/krivolapovdev/trenerio/pkg/types"
)

type UserResponse struct {
	ID    uuid.UUID `json:"id"`
	Email string    `json:"email"`
}

type OAuth2LoginRequest struct {
	Token string `json:"token" binding:"required"`
}

type RefreshTokenRequest struct {
	RefreshToken string `json:"refreshToken" binding:"required"`
}

type JwtResponse struct {
	AccessToken  string `json:"accessToken"`
	RefreshToken string `json:"refreshToken"`
}

type LoginResponse struct {
	User      UserResponse `json:"user"`
	JwtTokens JwtResponse  `json:"jwtTokens"`
}

type GroupResponse struct {
	ID           uuid.UUID `json:"id"`
	Name         string    `json:"name"`
	DefaultPrice *float64  `json:"defaultPrice,omitempty"`
	Note         *string   `json:"note,omitempty"`
	CreatedAt    time.Time `json:"createdAt"`
}

type GroupStudentResponse struct {
	ID        uuid.UUID `json:"id"`
	GroupID   uuid.UUID `json:"groupId"`
	StudentID uuid.UUID `json:"studentId"`
}

type GroupSummaryResponse struct {
	ID              uuid.UUID `json:"id"`
	Name            string    `json:"name"`
	DefaultPrice    *float64  `json:"defaultPrice,omitempty"`
	Note            *string   `json:"note,omitempty"`
	CreatedAt       time.Time `json:"createdAt"`
	CountOfStudents int64     `json:"countOfStudents"`
}

type GroupStudentSummaryResponse struct {
	ID        uuid.UUID             `json:"id"`
	FullName  string                `json:"fullName"`
	Birthdate *types.Date           `json:"birthdate,omitempty"`
	Phone     *string               `json:"phone,omitempty"`
	Note      *string               `json:"note,omitempty"`
	CreatedAt time.Time             `json:"createdAt"`
	Free      bool                  `json:"free"`
	Statuses  []types.StudentStatus `json:"statuses"`
}

type GroupReportStudentResponse struct {
	StudentID    uuid.UUID `json:"studentId"`
	FullName     string    `json:"fullName"`
	Paid         bool      `json:"paid"`
	PresentDays  []int     `json:"presentDays"`
	PresentCount int       `json:"presentCount"`
	LessonCount  int       `json:"lessonCount"`
}

type GroupReportResponse struct {
	GroupID      uuid.UUID                    `json:"groupId"`
	GroupName    string                       `json:"groupName"`
	Year         int                          `json:"year"`
	Month        int                          `json:"month"`
	DayCount     int                          `json:"dayCount"`
	LessonDays   []int                        `json:"lessonDays"`
	Students     []GroupReportStudentResponse `json:"students"`
	TotalPresent int                          `json:"totalPresent"`
	TotalLessons int                          `json:"totalLessons"`
}

type CreateGroupRequest struct {
	Name         string      `json:"name"`
	DefaultPrice *float64    `json:"defaultPrice"`
	Note         *string     `json:"note"`
	StudentIds   []uuid.UUID `json:"studentIds"`
}

type StudentResponse struct {
	ID        uuid.UUID   `json:"id"`
	FullName  string      `json:"fullName"`
	Birthdate *types.Date `json:"birthdate,omitempty"`
	Phone     *string     `json:"phone,omitempty"`
	Note      *string     `json:"note,omitempty"`
	CreatedAt time.Time   `json:"createdAt"`
	Free      bool        `json:"free"`
}

type StudentSummaryResponse struct {
	ID            uuid.UUID             `json:"id"`
	FullName      string                `json:"fullName"`
	Birthdate     *types.Date           `json:"birthdate,omitempty"`
	Phone         *string               `json:"phone,omitempty"`
	Note          *string               `json:"note,omitempty"`
	CreatedAt     time.Time             `json:"createdAt"`
	Free          bool                  `json:"free"`
	Statuses      []types.StudentStatus `json:"statuses"`
	StudentGroups []GroupResponse       `json:"studentGroups"`
}

type CreateStudentRequest struct {
	FullName  string      `json:"fullName"`
	Birthdate *types.Date `json:"birthdate"`
	Phone     *string     `json:"phone"`
	Note      *string     `json:"note"`
	Free      bool        `json:"free"`
}

type CreateStudentPaymentRequest struct {
	Amount    float64   `json:"amount" binding:"required"`
	Date      time.Time `json:"date" binding:"required"`
	PaidUntil time.Time `json:"paidUntil" binding:"required"`
}

type VisitResponse struct {
	ID        uuid.UUID         `json:"id"`
	Status    types.VisitStatus `json:"status"`
	Type      types.VisitType   `json:"type"`
	LessonID  uuid.UUID         `json:"lessonId"`
	StudentID uuid.UUID         `json:"studentId"`
	CreatedAt time.Time         `json:"createdAt"`
}

type StudentVisit struct {
	StudentID uuid.UUID         `json:"studentId"`
	Status    types.VisitStatus `json:"status"`
	Type      types.VisitType   `json:"type"`
}

type LessonResponse struct {
	ID        uuid.UUID  `json:"id"`
	Date      time.Time  `json:"date"`
	CreatedAt time.Time  `json:"createdAt"`
	GroupID   *uuid.UUID `json:"groupId,omitempty"`
}

type VisitWithLessonResponse struct {
	Visit  VisitResponse  `json:"visit"`
	Lesson LessonResponse `json:"lesson"`
}

type CreateLessonRequest struct {
	GroupID  *uuid.UUID     `json:"groupId"`
	Date     time.Time      `json:"date" binding:"required"`
	Students []StudentVisit `json:"students"`
}

type UpdateLessonRequest struct {
	Date     *time.Time     `json:"date"`
	Students []StudentVisit `json:"students"`
}

type LessonDetailsResponse struct {
	ID            uuid.UUID         `json:"id"`
	Date          time.Time         `json:"date"`
	CreatedAt     time.Time         `json:"createdAt"`
	GroupID       *uuid.UUID        `json:"groupId,omitempty"`
	StudentVisits []VisitResponse   `json:"studentVisits"`
	Students      []StudentResponse `json:"students"`
}

type StudentPaymentDetailsResponse struct {
	DetailsType string    `json:"detailsType"`
	StudentID   uuid.UUID `json:"studentId"`
	PaidUntil   time.Time `json:"paidUntil"`
	StudentName *string   `json:"studentName,omitempty"`
}

type CreateStudentPaymentDetailsRequest struct {
	DetailsType string     `json:"detailsType"`
	StudentID   uuid.UUID  `json:"studentId"`
	PaidUntil   time.Time  `json:"paidUntil"`
	PaidFrom    *time.Time `json:"paidFrom"`
}

type CreateTransactionRequest struct {
	Amount         float64                             `json:"amount"`
	Date           time.Time                           `json:"date"`
	Type           types.TransactionType               `json:"type"`
	PaymentDetails *CreateStudentPaymentDetailsRequest `json:"paymentDetails"`
}

type TransactionResponse struct {
	ID             uuid.UUID                      `json:"id"`
	Amount         float64                        `json:"amount"`
	Date           time.Time                      `json:"date"`
	Type           types.TransactionType          `json:"type"`
	CreatedAt      time.Time                      `json:"createdAt"`
	PaymentDetails *StudentPaymentDetailsResponse `json:"paymentDetails,omitempty"`
}

type SortObject struct {
	Empty    bool `json:"empty"`
	Sorted   bool `json:"sorted"`
	Unsorted bool `json:"unsorted"`
}

type PageableObject struct {
	Offset     int64       `json:"offset"`
	PageNumber int         `json:"pageNumber"`
	PageSize   int         `json:"pageSize"`
	Paged      bool        `json:"paged"`
	Unpaged    bool        `json:"unpaged"`
	Sort       *SortObject `json:"sort,omitempty"`
}

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

type PaymentMetricResponse struct {
	Date  time.Time `json:"date"`
	Total float64   `json:"total"`
}
