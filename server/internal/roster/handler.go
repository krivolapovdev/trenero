package roster

import (
	"context"
	"net/http"
	"strings"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/krivolapovdev/trenerio/internal/auth"
	pkgerrors "github.com/krivolapovdev/trenerio/internal/shared/errors"
	"github.com/krivolapovdev/trenerio/internal/shared/request"
	"github.com/krivolapovdev/trenerio/internal/shared/response"
	"github.com/krivolapovdev/trenerio/internal/shared/validator"
	"github.com/krivolapovdev/trenerio/internal/shared/web"
)

type rosterService interface {
	GetAllRosters(ctx context.Context, ownerID uuid.UUID) ([]response.RosterResponse, error)
	GetRosterByID(ctx context.Context, rosterID, ownerID uuid.UUID) (response.RosterResponse, error)
	GetRosterStudents(ctx context.Context, rosterID, ownerID uuid.UUID) ([]response.StudentResponse, error)
	CreateRoster(ctx context.Context, req request.CreateRosterRequest, ownerID uuid.UUID) (response.RosterResponse, error)
	UpdateRoster(ctx context.Context, rosterID, ownerID uuid.UUID, updates map[string]any) (response.RosterResponse, error)
	DeleteRoster(ctx context.Context, rosterID, ownerID uuid.UUID) error
	AddStudents(ctx context.Context, rosterID, ownerID uuid.UUID, studentIDs []uuid.UUID) (response.RosterResponse, error)
	RemoveStudent(ctx context.Context, rosterID, studentID, ownerID uuid.UUID) error
}

type Handler struct {
	service rosterService
}

func NewHandler(service rosterService) *Handler {
	return &Handler{
		service: service,
	}
}

// RegisterRoutes registers the roster routes onto the given router group.
func (h *Handler) RegisterRoutes(rg *gin.RouterGroup) {
	rosters := rg.Group("/rosters")
	{
		rosters.GET("", h.GetAllRosters)
		rosters.GET("/:rosterId", h.GetRosterByID)
		rosters.GET("/:rosterId/students", h.GetRosterStudents)
		rosters.POST("", h.CreateRoster)
		rosters.PATCH("/:rosterId", h.UpdateRoster)
		rosters.DELETE("/:rosterId", h.DeleteRoster)
		rosters.POST("/:rosterId/students", h.AddStudents)
		rosters.DELETE("/:rosterId/students/:studentId", h.RemoveStudent)
	}
}

// GetAllRosters
// @ID           getAllRosters
// @Tags         roster-controller
// @Security     BearerAuth
// @Success      200  {array}   response.RosterResponse
// @Router       /api/v1/rosters [get]
func (h *Handler) GetAllRosters(c *gin.Context) {
	jwtUser, ok := auth.GetUserFromContext(c)
	if !ok {
		return
	}

	rosters, err := h.service.GetAllRosters(c.Request.Context(), jwtUser.ID)
	if err != nil {
		pkgerrors.HandleError(c, err)
		return
	}

	c.JSON(http.StatusOK, rosters)
}

// GetRosterByID
// @ID           getRosterById
// @Tags         roster-controller
// @Security     BearerAuth
// @Param        rosterId  path      string  true  "Roster ID"  Format(uuid)
// @Success      200       {object}  response.RosterResponse
// @Router       /api/v1/rosters/{rosterId} [get]
func (h *Handler) GetRosterByID(c *gin.Context) {
	jwtUser, ok := auth.GetUserFromContext(c)
	if !ok {
		return
	}

	rosterID, ok := web.ParseUUIDParam(c, "rosterId")
	if !ok {
		return
	}

	roster, err := h.service.GetRosterByID(c.Request.Context(), rosterID, jwtUser.ID)
	if err != nil {
		pkgerrors.HandleError(c, err)
		return
	}

	c.JSON(http.StatusOK, roster)
}

// GetRosterStudents
// @ID           getRosterStudents
// @Tags         roster-controller
// @Security     BearerAuth
// @Param        rosterId  path      string  true  "Roster ID"  Format(uuid)
// @Success      200       {array}   response.StudentResponse
// @Router       /api/v1/rosters/{rosterId}/students [get]
func (h *Handler) GetRosterStudents(c *gin.Context) {
	jwtUser, ok := auth.GetUserFromContext(c)
	if !ok {
		return
	}

	rosterID, ok := web.ParseUUIDParam(c, "rosterId")
	if !ok {
		return
	}

	students, err := h.service.GetRosterStudents(c.Request.Context(), rosterID, jwtUser.ID)
	if err != nil {
		pkgerrors.HandleError(c, err)
		return
	}

	c.JSON(http.StatusOK, students)
}

// CreateRoster
// @ID           createRoster
// @Tags         roster-controller
// @Security     BearerAuth
// @Param        body  body      request.CreateRosterRequest  true  "Create roster request"
// @Success      201   {object}  response.RosterResponse
// @Router       /api/v1/rosters [post]
func (h *Handler) CreateRoster(c *gin.Context) {
	jwtUser, ok := auth.GetUserFromContext(c)
	if !ok {
		return
	}

	var req request.CreateRosterRequest
	if !web.BindJSON(c, &req) {
		return
	}

	trimmedName, err := validator.ValidateRequiredName(req.Name, "name")
	if err != nil {
		pkgerrors.HandleError(c, err)
		return
	}
	req.Name = trimmedName
	req.Note = validator.TrimStringPtr(req.Note)

	createdRoster, err := h.service.CreateRoster(c.Request.Context(), req, jwtUser.ID)
	if err != nil {
		pkgerrors.HandleError(c, err)
		return
	}

	c.JSON(http.StatusCreated, createdRoster)
}

// UpdateRoster
// @ID           updateRoster
// @Tags         roster-controller
// @Security     BearerAuth
// @Param        rosterId  path      string             true  "Roster ID"          Format(uuid)
// @Param        body      body      map[string]object  true  "Fields to update"
// @Success      200       {object}  response.RosterResponse
// @Router       /api/v1/rosters/{rosterId} [patch]
func (h *Handler) UpdateRoster(c *gin.Context) {
	jwtUser, ok := auth.GetUserFromContext(c)
	if !ok {
		return
	}

	rosterID, ok := web.ParseUUIDParam(c, "rosterId")
	if !ok {
		return
	}

	var updates map[string]any
	if !web.BindJSON(c, &updates) {
		return
	}

	if rawName, ok := updates["name"]; ok && rawName != nil {
		if nameStr, ok := rawName.(string); ok {
			trimmedName, err := validator.ValidateRequiredName(nameStr, "name")
			if err != nil {
				pkgerrors.HandleError(c, err)
				return
			}
			updates["name"] = trimmedName
		} else {
			pkgerrors.RespondBadRequest(c, "name must not be blank")
			return
		}
	}
	if rawNote, ok := updates["note"]; ok && rawNote != nil {
		if noteStr, ok := rawNote.(string); ok {
			updates["note"] = strings.TrimSpace(noteStr)
		}
	}

	updatedRoster, err := h.service.UpdateRoster(c.Request.Context(), rosterID, jwtUser.ID, updates)
	if err != nil {
		pkgerrors.HandleError(c, err)
		return
	}

	c.JSON(http.StatusOK, updatedRoster)
}

// DeleteRoster
// @ID           deleteRoster
// @Tags         roster-controller
// @Security     BearerAuth
// @Param        rosterId  path  string  true  "Roster ID"  Format(uuid)
// @Success      204       "No Content"
// @Router       /api/v1/rosters/{rosterId} [delete]
func (h *Handler) DeleteRoster(c *gin.Context) {
	jwtUser, ok := auth.GetUserFromContext(c)
	if !ok {
		return
	}

	rosterID, ok := web.ParseUUIDParam(c, "rosterId")
	if !ok {
		return
	}

	if err := h.service.DeleteRoster(c.Request.Context(), rosterID, jwtUser.ID); err != nil {
		pkgerrors.HandleError(c, err)
		return
	}

	c.Status(http.StatusNoContent)
}

// AddStudents
// @ID           addStudentsToRoster
// @Tags         roster-controller
// @Security     BearerAuth
// @Param        rosterId  path      string                            true  "Roster ID"  Format(uuid)
// @Param        body      body      request.AddRosterStudentsRequest  true  "Students to add"
// @Success      200       {object}  response.RosterResponse
// @Router       /api/v1/rosters/{rosterId}/students [post]
func (h *Handler) AddStudents(c *gin.Context) {
	jwtUser, ok := auth.GetUserFromContext(c)
	if !ok {
		return
	}

	rosterID, ok := web.ParseUUIDParam(c, "rosterId")
	if !ok {
		return
	}

	var req request.AddRosterStudentsRequest
	if !web.BindJSON(c, &req) {
		return
	}

	updatedRoster, err := h.service.AddStudents(c.Request.Context(), rosterID, jwtUser.ID, req.StudentIds)
	if err != nil {
		pkgerrors.HandleError(c, err)
		return
	}

	c.JSON(http.StatusOK, updatedRoster)
}

// RemoveStudent
// @ID           removeStudentFromRoster
// @Tags         roster-controller
// @Security     BearerAuth
// @Param        rosterId   path  string  true  "Roster ID"   Format(uuid)
// @Param        studentId  path  string  true  "Student ID"  Format(uuid)
// @Success      204        "No Content"
// @Router       /api/v1/rosters/{rosterId}/students/{studentId} [delete]
func (h *Handler) RemoveStudent(c *gin.Context) {
	jwtUser, ok := auth.GetUserFromContext(c)
	if !ok {
		return
	}

	rosterID, ok := web.ParseUUIDParam(c, "rosterId")
	if !ok {
		return
	}

	studentID, ok := web.ParseUUIDParam(c, "studentId")
	if !ok {
		return
	}

	if err := h.service.RemoveStudent(c.Request.Context(), rosterID, studentID, jwtUser.ID); err != nil {
		pkgerrors.HandleError(c, err)
		return
	}

	c.Status(http.StatusNoContent)
}
