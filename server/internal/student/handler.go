package student

import (
	"context"
	"net/http"
	"strings"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/krivolapovdev/trenerio/internal/auth"
	pkgerrors "github.com/krivolapovdev/trenerio/internal/shared/errors"
	"github.com/krivolapovdev/trenerio/internal/shared/request"
	"github.com/krivolapovdev/trenerio/internal/shared/response"
	"github.com/krivolapovdev/trenerio/internal/shared/validator"
	"github.com/krivolapovdev/trenerio/internal/shared/web"
	"github.com/krivolapovdev/trenerio/internal/transaction"
)

type studentService interface {
	GetAllStudentsSummary(ctx context.Context, ownerID uuid.UUID) ([]StudentSummaryResponse, error)
	GetStudentVisits(ctx context.Context, studentID, ownerID uuid.UUID, from, to *time.Time) ([]response.VisitWithLessonResponse, error)
	GetStudentPayments(ctx context.Context, studentID, ownerID uuid.UUID) ([]transaction.TransactionResponse, error)
	GetStudentDetailsByID(ctx context.Context, studentID, ownerID uuid.UUID) (response.StudentResponse, error)
	CreateStudent(ctx context.Context, req request.CreateStudentRequest, ownerID uuid.UUID) (response.StudentResponse, error)
	CreateStudentPayment(ctx context.Context, studentID, ownerID uuid.UUID, req request.CreateStudentPaymentRequest) (transaction.TransactionResponse, error)
	UpdateStudent(ctx context.Context, studentID, ownerID uuid.UUID, updates map[string]any) (response.StudentResponse, error)
	DeleteStudent(ctx context.Context, studentID, ownerID uuid.UUID) error
}

type Handler struct {
	service studentService
}

func NewHandler(service studentService) *Handler {
	return &Handler{
		service: service,
	}
}

// RegisterRoutes registers the student routes onto the given router group.
func (h *Handler) RegisterRoutes(rg *gin.RouterGroup) {
	students := rg.Group("/students")
	{
		students.GET("", h.GetAllStudentsSummary)
		students.GET("/overview", h.GetAllStudentsSummary)
		students.GET("/:studentId/visits", h.GetStudentVisits)
		students.GET("/:studentId/payments", h.GetStudentPayments)
		students.POST("", h.CreateStudent)
		students.POST("/:studentId/payments", h.CreateStudentPayment)
		students.PATCH("/:studentId", h.UpdateStudent)
		students.DELETE("/:studentId", h.DeleteStudent)
	}
}

// GetAllStudentsSummary
// @ID           getStudentsSummary
// @Tags         student-controller
// @Security     BearerAuth
// @Success      200  {array}   StudentSummaryResponse
// @Router       /api/v1/students/overview [get]
func (h *Handler) GetAllStudentsSummary(c *gin.Context) {
	jwtUser, ok := auth.GetUserFromContext(c)
	if !ok {
		return
	}

	summaries, err := h.service.GetAllStudentsSummary(c.Request.Context(), jwtUser.ID)
	if err != nil {
		pkgerrors.HandleError(c, err)
		return
	}

	c.JSON(http.StatusOK, summaries)
}

// GetStudentVisits
// @ID           getStudentVisits
// @Tags         student-controller
// @Security     BearerAuth
// @Param        studentId  path      string  true   "Student ID"             Format(uuid)
// @Param        from       query     string  false  "Start date (RFC3339)"   Format(date-time)
// @Param        to         query     string  false  "End date (RFC3339)"     Format(date-time)
// @Success      200        {array}   response.VisitWithLessonResponse
// @Router       /api/v1/students/{studentId}/visits [get]
func (h *Handler) GetStudentVisits(c *gin.Context) {
	jwtUser, ok := auth.GetUserFromContext(c)
	if !ok {
		return
	}

	studentID, ok := web.ParseUUIDParam(c, "studentId")
	if !ok {
		return
	}

	fromPtr := web.ParseOptionalRFC3339(c, "from")
	toPtr := web.ParseOptionalRFC3339(c, "to")

	visits, err := h.service.GetStudentVisits(c.Request.Context(), studentID, jwtUser.ID, fromPtr, toPtr)
	if err != nil {
		pkgerrors.HandleError(c, err)
		return
	}

	c.JSON(http.StatusOK, visits)
}

// GetStudentPayments
// @ID           getStudentPayments
// @Tags         student-controller
// @Security     BearerAuth
// @Param        studentId  path      string  true  "Student ID"  Format(uuid)
// @Success      200        {array}   transaction.TransactionResponse
// @Router       /api/v1/students/{studentId}/payments [get]
func (h *Handler) GetStudentPayments(c *gin.Context) {
	jwtUser, ok := auth.GetUserFromContext(c)
	if !ok {
		return
	}

	studentID, ok := web.ParseUUIDParam(c, "studentId")
	if !ok {
		return
	}

	payments, err := h.service.GetStudentPayments(c.Request.Context(), studentID, jwtUser.ID)
	if err != nil {
		pkgerrors.HandleError(c, err)
		return
	}

	c.JSON(http.StatusOK, payments)
}

// CreateStudent
// @ID           createStudent
// @Tags         student-controller
// @Security     BearerAuth
// @Param        body  body      request.CreateStudentRequest  true  "Create student request"
// @Success      201   {object}  response.StudentResponse
// @Router       /api/v1/students [post]
func (h *Handler) CreateStudent(c *gin.Context) {
	jwtUser, ok := auth.GetUserFromContext(c)
	if !ok {
		return
	}

	var req request.CreateStudentRequest
	if !web.BindJSON(c, &req) {
		return
	}

	var err error
	req.FullName, err = validator.ValidateRequiredName(req.FullName, "fullName")
	if err != nil {
		pkgerrors.HandleError(c, err)
		return
	}
	req.Phone = validator.TrimStringPtr(req.Phone)
	req.Note = validator.TrimStringPtr(req.Note)

	createdStudent, err := h.service.CreateStudent(c.Request.Context(), req, jwtUser.ID)
	if err != nil {
		pkgerrors.HandleError(c, err)
		return
	}

	c.JSON(http.StatusCreated, createdStudent)
}

// CreateStudentPayment
// @ID           createStudentPayment
// @Tags         student-controller
// @Security     BearerAuth
// @Param        studentId  path      string                              true  "Student ID"              Format(uuid)
// @Param        body       body      request.CreateStudentPaymentRequest  true  "Student payment request"
// @Success      201        {object}  transaction.TransactionResponse
// @Router       /api/v1/students/{studentId}/payments [post]
func (h *Handler) CreateStudentPayment(c *gin.Context) {
	jwtUser, ok := auth.GetUserFromContext(c)
	if !ok {
		return
	}

	studentID, ok := web.ParseUUIDParam(c, "studentId")
	if !ok {
		return
	}

	var req request.CreateStudentPaymentRequest
	if !web.BindJSON(c, &req) {
		return
	}

	payment, err := h.service.CreateStudentPayment(c.Request.Context(), studentID, jwtUser.ID, req)
	if err != nil {
		pkgerrors.HandleError(c, err)
		return
	}

	c.JSON(http.StatusCreated, payment)
}

// UpdateStudent
// @ID           updateStudent
// @Tags         student-controller
// @Security     BearerAuth
// @Param        studentId  path      string             true  "Student ID"        Format(uuid)
// @Param        body       body      map[string]object  true  "Fields to update"
// @Success      200        {object}  response.StudentResponse
// @Router       /api/v1/students/{studentId} [patch]
func (h *Handler) UpdateStudent(c *gin.Context) {
	jwtUser, ok := auth.GetUserFromContext(c)
	if !ok {
		return
	}

	studentID, ok := web.ParseUUIDParam(c, "studentId")
	if !ok {
		return
	}

	var updates map[string]any
	if !web.BindJSON(c, &updates) {
		return
	}

	if rawName, ok := updates["fullName"]; ok && rawName != nil {
		if nameStr, ok := rawName.(string); ok {
			trimmedName, err := validator.ValidateRequiredName(nameStr, "fullName")
			if err != nil {
				pkgerrors.HandleError(c, err)
				return
			}
			updates["fullName"] = trimmedName
		} else {
			pkgerrors.RespondBadRequest(c, "fullName must not be blank")
			return
		}
	}
	if rawPhone, ok := updates["phone"]; ok && rawPhone != nil {
		if phoneStr, ok := rawPhone.(string); ok {
			updates["phone"] = strings.TrimSpace(phoneStr)
		}
	}
	if rawNote, ok := updates["note"]; ok && rawNote != nil {
		if noteStr, ok := rawNote.(string); ok {
			updates["note"] = strings.TrimSpace(noteStr)
		}
	}

	updatedStudent, err := h.service.UpdateStudent(c.Request.Context(), studentID, jwtUser.ID, updates)
	if err != nil {
		pkgerrors.HandleError(c, err)
		return
	}

	c.JSON(http.StatusOK, updatedStudent)
}

// DeleteStudent
// @ID           deleteStudent
// @Tags         student-controller
// @Security     BearerAuth
// @Param        studentId  path  string  true  "Student ID"  Format(uuid)
// @Success      204        "No Content"
// @Router       /api/v1/students/{studentId} [delete]
func (h *Handler) DeleteStudent(c *gin.Context) {
	jwtUser, ok := auth.GetUserFromContext(c)
	if !ok {
		return
	}

	studentID, ok := web.ParseUUIDParam(c, "studentId")
	if !ok {
		return
	}

	if err := h.service.DeleteStudent(c.Request.Context(), studentID, jwtUser.ID); err != nil {
		pkgerrors.HandleError(c, err)
		return
	}

	c.Status(http.StatusNoContent)
}
