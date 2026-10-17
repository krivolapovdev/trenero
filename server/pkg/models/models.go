package models

import (
	"github.com/krivolapovdev/trenerio/pkg/models/request"
	"github.com/krivolapovdev/trenerio/pkg/models/response"
)

// Re-export response models
type (
	UserResponse                  = response.UserResponse
	JwtResponse                   = response.JwtResponse
	LoginResponse                 = response.LoginResponse
	GroupResponse                 = response.GroupResponse
	GroupStudentResponse          = response.GroupStudentResponse
	GroupSummaryResponse          = response.GroupSummaryResponse
	GroupStudentSummaryResponse   = response.GroupStudentSummaryResponse
	GroupReportStudentResponse    = response.GroupReportStudentResponse
	GroupReportResponse           = response.GroupReportResponse
	StudentResponse               = response.StudentResponse
	StudentSummaryResponse        = response.StudentSummaryResponse
	VisitResponse                 = response.VisitResponse
	VisitWithLessonResponse       = response.VisitWithLessonResponse
	LessonResponse                = response.LessonResponse
	LessonDetailsResponse         = response.LessonDetailsResponse
	StudentPaymentDetailsResponse = response.StudentPaymentDetailsResponse
	TransactionResponse           = response.TransactionResponse
	SortObject                    = response.SortObject
	PageableObject                = response.PageableObject
	PageTransactionResponse       = response.PageTransactionResponse
	PaymentMetricResponse         = response.PaymentMetricResponse
)

// Re-export request models
type (
	OAuth2LoginRequest                 = request.OAuth2LoginRequest
	RefreshTokenRequest                = request.RefreshTokenRequest
	CreateGroupRequest                 = request.CreateGroupRequest
	CreateStudentRequest               = request.CreateStudentRequest
	CreateStudentPaymentRequest        = request.CreateStudentPaymentRequest
	StudentVisit                       = request.StudentVisit
	CreateLessonRequest                = request.CreateLessonRequest
	UpdateLessonRequest                = request.UpdateLessonRequest
	CreateStudentPaymentDetailsRequest = request.CreateStudentPaymentDetailsRequest
	CreateTransactionRequest           = request.CreateTransactionRequest
)
