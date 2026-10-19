package group

import (
	"context"
	"net/http"
	"strconv"
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
)

type groupService interface {
	GetAllGroupsSummary(ctx context.Context, ownerID uuid.UUID) ([]response.GroupSummaryResponse, error)
	GetGroupStudents(ctx context.Context, groupID, ownerID uuid.UUID) ([]GroupStudentSummaryResponse, error)
	GetGroupLessons(ctx context.Context, groupID, ownerID uuid.UUID, from, to time.Time) ([]response.LessonResponse, error)
	GetGroupReport(ctx context.Context, groupID, ownerID uuid.UUID, year, month int) (GroupReportResponse, error)
	CreateGroup(ctx context.Context, req request.CreateGroupRequest, ownerID uuid.UUID) (response.GroupResponse, error)
	UpdateGroup(ctx context.Context, groupID, ownerID uuid.UUID, updates map[string]any) (response.GroupResponse, error)
	DeleteGroup(ctx context.Context, groupID, ownerID uuid.UUID) error
}

type Handler struct {
	service groupService
}

func NewHandler(service groupService) *Handler {
	return &Handler{
		service: service,
	}
}

// RegisterRoutes registers the group routes onto the given router group.
func (h *Handler) RegisterRoutes(rg *gin.RouterGroup) {
	groups := rg.Group("/groups")
	{
		groups.GET("", h.GetAllGroupsSummary)
		groups.GET("/:groupId/students", h.GetGroupStudents)
		groups.GET("/:groupId/lessons", h.GetGroupLessons)
		groups.GET("/:groupId/report", h.GetGroupReport)
		groups.POST("", h.CreateGroup)
		groups.PATCH("/:groupId", h.UpdateGroup)
		groups.DELETE("/:groupId", h.DeleteGroup)
	}
}

// GetAllGroupsSummary
// @ID           getAllGroupsSummary
// @Tags         group-controller
// @Security     BearerAuth
// @Success      200  {array}   response.GroupSummaryResponse
// @Router       /api/v1/groups [get]
func (h *Handler) GetAllGroupsSummary(c *gin.Context) {
	jwtUser, ok := auth.GetUserFromContext(c)
	if !ok {
		return
	}

	summaries, err := h.service.GetAllGroupsSummary(c.Request.Context(), jwtUser.ID)
	if err != nil {
		pkgerrors.HandleError(c, err)
		return
	}

	c.JSON(http.StatusOK, summaries)
}

// GetGroupStudents
// @ID           getGroupStudents
// @Tags         group-controller
// @Security     BearerAuth
// @Param        groupId  path      string  true  "Group ID"  Format(uuid)
// @Success      200      {array}   GroupStudentSummaryResponse
// @Router       /api/v1/groups/{groupId}/students [get]
func (h *Handler) GetGroupStudents(c *gin.Context) {
	jwtUser, ok := auth.GetUserFromContext(c)
	if !ok {
		return
	}

	groupID, ok := web.ParseUUIDParam(c, "groupId")
	if !ok {
		return
	}

	students, err := h.service.GetGroupStudents(c.Request.Context(), groupID, jwtUser.ID)
	if err != nil {
		pkgerrors.HandleError(c, err)
		return
	}

	c.JSON(http.StatusOK, students)
}

// GetGroupLessons
// @ID           getGroupLessons
// @Tags         group-controller
// @Security     BearerAuth
// @Param        groupId  path      string  true  "Group ID"               Format(uuid)
// @Param        from     query     string  true  "Start date (RFC3339)"   Format(date-time)
// @Param        to       query     string  true  "End date (RFC3339)"     Format(date-time)
// @Success      200      {array}   response.LessonResponse
// @Router       /api/v1/groups/{groupId}/lessons [get]
func (h *Handler) GetGroupLessons(c *gin.Context) {
	jwtUser, ok := auth.GetUserFromContext(c)
	if !ok {
		return
	}

	groupID, ok := web.ParseUUIDParam(c, "groupId")
	if !ok {
		return
	}

	from, to, ok := web.ParseRequiredRFC3339Range(c, "from", "to", "from and to query parameters are required")
	if !ok {
		return
	}

	lessons, err := h.service.GetGroupLessons(c.Request.Context(), groupID, jwtUser.ID, from, to)
	if err != nil {
		pkgerrors.HandleError(c, err)
		return
	}

	c.JSON(http.StatusOK, lessons)
}

// GetGroupReport
// @ID           getGroupReport
// @Tags         group-controller
// @Security     BearerAuth
// @Param        groupId  path      string  true  "Group ID"  Format(uuid)
// @Param        year     query     int     true  "Year"
// @Param        month    query     int     true  "Month"
// @Success      200      {object}  GroupReportResponse
// @Router       /api/v1/groups/{groupId}/report [get]
func (h *Handler) GetGroupReport(c *gin.Context) {
	jwtUser, ok := auth.GetUserFromContext(c)
	if !ok {
		return
	}

	groupID, ok := web.ParseUUIDParam(c, "groupId")
	if !ok {
		return
	}

	yearStr := c.Query("year")
	monthStr := c.Query("month")
	if yearStr == "" || monthStr == "" {
		pkgerrors.RespondBadRequest(c, "year and month query parameters are required")
		return
	}

	year, err := strconv.Atoi(yearStr)
	if err != nil || year < 1 {
		pkgerrors.RespondBadRequest(c, "Invalid year")
		return
	}

	month, err := strconv.Atoi(monthStr)
	if err != nil || month < 1 || month > 12 {
		pkgerrors.RespondBadRequest(c, "Invalid month")
		return
	}

	report, err := h.service.GetGroupReport(c.Request.Context(), groupID, jwtUser.ID, year, month)
	if err != nil {
		pkgerrors.HandleError(c, err)
		return
	}

	c.JSON(http.StatusOK, report)
}

// CreateGroup
// @ID           createGroup
// @Tags         group-controller
// @Security     BearerAuth
// @Param        body  body      request.CreateGroupRequest  true  "Create group request"
// @Success      201   {object}  response.GroupResponse
// @Router       /api/v1/groups [post]
func (h *Handler) CreateGroup(c *gin.Context) {
	jwtUser, ok := auth.GetUserFromContext(c)
	if !ok {
		return
	}

	var req request.CreateGroupRequest
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

	createdGroup, err := h.service.CreateGroup(c.Request.Context(), req, jwtUser.ID)
	if err != nil {
		pkgerrors.HandleError(c, err)
		return
	}

	c.JSON(http.StatusCreated, createdGroup)
}

// UpdateGroup
// @ID           updateGroup
// @Tags         group-controller
// @Security     BearerAuth
// @Param        groupId  path      string             true  "Group ID"          Format(uuid)
// @Param        body     body      map[string]object  true  "Fields to update"
// @Success      200      {object}  response.GroupResponse
// @Router       /api/v1/groups/{groupId} [patch]
func (h *Handler) UpdateGroup(c *gin.Context) {
	jwtUser, ok := auth.GetUserFromContext(c)
	if !ok {
		return
	}

	groupID, ok := web.ParseUUIDParam(c, "groupId")
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

	updatedGroup, err := h.service.UpdateGroup(c.Request.Context(), groupID, jwtUser.ID, updates)
	if err != nil {
		pkgerrors.HandleError(c, err)
		return
	}

	c.JSON(http.StatusOK, updatedGroup)
}

// DeleteGroup
// @ID           deleteGroup
// @Tags         group-controller
// @Security     BearerAuth
// @Param        groupId  path  string  true  "Group ID"  Format(uuid)
// @Success      204      "No Content"
// @Router       /api/v1/groups/{groupId} [delete]
func (h *Handler) DeleteGroup(c *gin.Context) {
	jwtUser, ok := auth.GetUserFromContext(c)
	if !ok {
		return
	}

	groupID, ok := web.ParseUUIDParam(c, "groupId")
	if !ok {
		return
	}

	if err := h.service.DeleteGroup(c.Request.Context(), groupID, jwtUser.ID); err != nil {
		pkgerrors.HandleError(c, err)
		return
	}

	c.Status(http.StatusNoContent)
}
