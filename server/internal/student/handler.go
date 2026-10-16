package student

import (
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	pkgerrors "github.com/krivolapovdev/trenerio/pkg/errors"
	"github.com/krivolapovdev/trenerio/pkg/models"
	"github.com/krivolapovdev/trenerio/pkg/security"
	"github.com/krivolapovdev/trenerio/pkg/types"
)

type Handler struct {
	service *Service
}

func NewHandler(service *Service) *Handler {
	return &Handler{
		service: service,
	}
}

func getAuthUser(c *gin.Context) (security.JwtUser, bool) {
	val, exists := c.Get(types.ContextKeyJWTUser)
	if !exists {
		pkgerrors.RespondUnauthorized(c, "")
		c.Abort()
		return security.JwtUser{}, false
	}
	u, ok := val.(security.JwtUser)
	if !ok {
		pkgerrors.RespondUnauthorized(c, "")
		c.Abort()
		return security.JwtUser{}, false
	}
	return u, true
}

// GetAllStudentsSummary
// @ID           getStudentsSummary
// @Tags         student-controller
// @Security     BearerAuth
// @Success      200  {array}   models.StudentSummaryResponse
// @Router       /api/v1/students/overview [get]
func (h *Handler) GetAllStudentsSummary(c *gin.Context) {
	jwtUser, ok := getAuthUser(c)
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
// @Success      200        {array}   models.VisitWithLessonResponse
// @Router       /api/v1/students/{studentId}/visits [get]
func (h *Handler) GetStudentVisits(c *gin.Context) {
	jwtUser, ok := getAuthUser(c)
	if !ok {
		return
	}

	studentID, err := uuid.Parse(c.Param("studentId"))
	if err != nil {
		pkgerrors.RespondBadRequest(c, "Invalid studentId")
		return
	}

	var fromPtr, toPtr *time.Time
	if fromStr := c.Query("from"); fromStr != "" {
		if t, err := time.Parse(time.RFC3339, fromStr); err == nil {
			fromPtr = &t
		}
	}
	if toStr := c.Query("to"); toStr != "" {
		if t, err := time.Parse(time.RFC3339, toStr); err == nil {
			toPtr = &t
		}
	}

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
// @Success      200        {array}   models.TransactionResponse
// @Router       /api/v1/students/{studentId}/payments [get]
func (h *Handler) GetStudentPayments(c *gin.Context) {
	jwtUser, ok := getAuthUser(c)
	if !ok {
		return
	}

	studentID, err := uuid.Parse(c.Param("studentId"))
	if err != nil {
		pkgerrors.RespondBadRequest(c, "Invalid studentId")
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
// @Param        body  body      models.CreateStudentRequest  true  "Create student request"
// @Success      201   {object}  models.StudentResponse
// @Router       /api/v1/students [post]
func (h *Handler) CreateStudent(c *gin.Context) {
	jwtUser, ok := getAuthUser(c)
	if !ok {
		return
	}

	var req models.CreateStudentRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		pkgerrors.RespondBadRequest(c, "Request body is missing or has invalid format")
		return
	}

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
// @Param        body       body      models.CreateStudentPaymentRequest  true  "Student payment request"
// @Success      201        {object}  models.TransactionResponse
// @Router       /api/v1/students/{studentId}/payments [post]
func (h *Handler) CreateStudentPayment(c *gin.Context) {
	jwtUser, ok := getAuthUser(c)
	if !ok {
		return
	}

	studentID, err := uuid.Parse(c.Param("studentId"))
	if err != nil {
		pkgerrors.RespondBadRequest(c, "Invalid studentId")
		return
	}

	var req models.CreateStudentPaymentRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		pkgerrors.RespondBadRequest(c, "Request body is missing or has invalid format")
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
// @Success      200        {object}  models.StudentResponse
// @Router       /api/v1/students/{studentId} [patch]
func (h *Handler) UpdateStudent(c *gin.Context) {
	jwtUser, ok := getAuthUser(c)
	if !ok {
		return
	}

	studentID, err := uuid.Parse(c.Param("studentId"))
	if err != nil {
		pkgerrors.RespondBadRequest(c, "Invalid studentId")
		return
	}

	var updates map[string]any
	if err := c.ShouldBindJSON(&updates); err != nil {
		pkgerrors.RespondBadRequest(c, "Request body is missing or has invalid format")
		return
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
	jwtUser, ok := getAuthUser(c)
	if !ok {
		return
	}

	studentID, err := uuid.Parse(c.Param("studentId"))
	if err != nil {
		pkgerrors.RespondBadRequest(c, "Invalid studentId")
		return
	}

	if err := h.service.DeleteStudent(c.Request.Context(), studentID, jwtUser.ID); err != nil {
		pkgerrors.HandleError(c, err)
		return
	}

	c.Status(http.StatusNoContent)
}
