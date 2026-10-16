package student

import (
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	pkgerrors "github.com/krivolapovdev/trenerio/pkg/errors"
	"github.com/krivolapovdev/trenerio/pkg/models"
	"github.com/krivolapovdev/trenerio/pkg/security"
)

type Handler struct {
	service *Service
}

func NewHandler(service *Service) *Handler {
	return &Handler{
		service: service,
	}
}

// GetAllStudentsSummary
// @ID           getStudentsSummary
// @Tags         student-controller
// @Security     BearerAuth
// @Success      200  {array}   models.StudentSummaryResponse
// @Router       /api/v1/students/overview [get]
func (h *Handler) GetAllStudentsSummary(c *gin.Context) {
	jwtUser, ok := c.MustGet("jwtUser").(security.JwtUser)
	if !ok {
		pkgerrors.RespondUnauthorized(c, "")
		return
	}

	resp, err := h.service.GetAllStudentsSummary(c.Request.Context(), jwtUser.ID)
	if err != nil {
		pkgerrors.HandleError(c, err)
		return
	}

	c.JSON(http.StatusOK, resp)
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
	jwtUser, ok := c.MustGet("jwtUser").(security.JwtUser)
	if !ok {
		pkgerrors.RespondUnauthorized(c, "")
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

	resp, err := h.service.GetStudentVisits(c.Request.Context(), studentID, jwtUser.ID, fromPtr, toPtr)
	if err != nil {
		pkgerrors.HandleError(c, err)
		return
	}

	c.JSON(http.StatusOK, resp)
}

// GetStudentPayments
// @ID           getStudentPayments
// @Tags         student-controller
// @Security     BearerAuth
// @Param        studentId  path      string  true  "Student ID"  Format(uuid)
// @Success      200        {array}   models.TransactionResponse
// @Router       /api/v1/students/{studentId}/payments [get]
func (h *Handler) GetStudentPayments(c *gin.Context) {
	jwtUser, ok := c.MustGet("jwtUser").(security.JwtUser)
	if !ok {
		pkgerrors.RespondUnauthorized(c, "")
		return
	}

	studentID, err := uuid.Parse(c.Param("studentId"))
	if err != nil {
		pkgerrors.RespondBadRequest(c, "Invalid studentId")
		return
	}

	resp, err := h.service.GetStudentPayments(c.Request.Context(), studentID, jwtUser.ID)
	if err != nil {
		pkgerrors.HandleError(c, err)
		return
	}

	c.JSON(http.StatusOK, resp)
}

// CreateStudent
// @ID           createStudent
// @Tags         student-controller
// @Security     BearerAuth
// @Param        body  body      models.CreateStudentRequest  true  "Create student request"
// @Success      201   {object}  models.StudentResponse
// @Router       /api/v1/students [post]
func (h *Handler) CreateStudent(c *gin.Context) {
	jwtUser, ok := c.MustGet("jwtUser").(security.JwtUser)
	if !ok {
		pkgerrors.RespondUnauthorized(c, "")
		return
	}

	var req models.CreateStudentRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		pkgerrors.RespondBadRequest(c, "Request body is missing or has invalid format")
		return
	}

	resp, err := h.service.CreateStudent(c.Request.Context(), req, jwtUser.ID)
	if err != nil {
		pkgerrors.HandleError(c, err)
		return
	}

	c.JSON(http.StatusCreated, resp)
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
	jwtUser, ok := c.MustGet("jwtUser").(security.JwtUser)
	if !ok {
		pkgerrors.RespondUnauthorized(c, "")
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

	resp, err := h.service.CreateStudentPayment(c.Request.Context(), studentID, jwtUser.ID, req)
	if err != nil {
		pkgerrors.HandleError(c, err)
		return
	}

	c.JSON(http.StatusCreated, resp)
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
	jwtUser, ok := c.MustGet("jwtUser").(security.JwtUser)
	if !ok {
		pkgerrors.RespondUnauthorized(c, "")
		return
	}

	studentID, err := uuid.Parse(c.Param("studentId"))
	if err != nil {
		pkgerrors.RespondBadRequest(c, "Invalid studentId")
		return
	}

	var updates map[string]interface{}
	if err := c.ShouldBindJSON(&updates); err != nil {
		pkgerrors.RespondBadRequest(c, "Request body is missing or has invalid format")
		return
	}

	resp, err := h.service.UpdateStudent(c.Request.Context(), studentID, jwtUser.ID, updates)
	if err != nil {
		pkgerrors.HandleError(c, err)
		return
	}

	c.JSON(http.StatusOK, resp)
}

// DeleteStudent
// @ID           deleteStudent
// @Tags         student-controller
// @Security     BearerAuth
// @Param        studentId  path  string  true  "Student ID"  Format(uuid)
// @Success      204        "No Content"
// @Router       /api/v1/students/{studentId} [delete]
func (h *Handler) DeleteStudent(c *gin.Context) {
	jwtUser, ok := c.MustGet("jwtUser").(security.JwtUser)
	if !ok {
		pkgerrors.RespondUnauthorized(c, "")
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
