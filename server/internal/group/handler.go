package group

import (
	"net/http"
	"strconv"
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

// GetAllGroupsSummary
// @ID           getAllGroupsSummary
// @Tags         group-controller
// @Security     BearerAuth
// @Success      200  {array}   models.GroupSummaryResponse
// @Router       /api/v1/groups [get]
func (h *Handler) GetAllGroupsSummary(c *gin.Context) {
	jwtUser, ok := getAuthUser(c)
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
// @Success      200      {array}   models.GroupStudentSummaryResponse
// @Router       /api/v1/groups/{groupId}/students [get]
func (h *Handler) GetGroupStudents(c *gin.Context) {
	jwtUser, ok := getAuthUser(c)
	if !ok {
		return
	}

	groupID, err := uuid.Parse(c.Param("groupId"))
	if err != nil {
		pkgerrors.RespondBadRequest(c, "Invalid groupId")
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
// @Success      200      {array}   models.LessonResponse
// @Router       /api/v1/groups/{groupId}/lessons [get]
func (h *Handler) GetGroupLessons(c *gin.Context) {
	jwtUser, ok := getAuthUser(c)
	if !ok {
		return
	}

	groupID, err := uuid.Parse(c.Param("groupId"))
	if err != nil {
		pkgerrors.RespondBadRequest(c, "Invalid groupId")
		return
	}

	fromStr := c.Query("from")
	toStr := c.Query("to")
	if fromStr == "" || toStr == "" {
		pkgerrors.RespondBadRequest(c, "from and to query parameters are required")
		return
	}

	from, err := time.Parse(time.RFC3339, fromStr)
	if err != nil {
		pkgerrors.RespondBadRequest(c, "Invalid from date format")
		return
	}

	to, err := time.Parse(time.RFC3339, toStr)
	if err != nil {
		pkgerrors.RespondBadRequest(c, "Invalid to date format")
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
// @Success      200      {object}  models.GroupReportResponse
// @Router       /api/v1/groups/{groupId}/report [get]
func (h *Handler) GetGroupReport(c *gin.Context) {
	jwtUser, ok := getAuthUser(c)
	if !ok {
		return
	}

	groupID, err := uuid.Parse(c.Param("groupId"))
	if err != nil {
		pkgerrors.RespondBadRequest(c, "Invalid groupId")
		return
	}

	yearStr := c.Query("year")
	monthStr := c.Query("month")
	if yearStr == "" || monthStr == "" {
		pkgerrors.RespondBadRequest(c, "year and month query parameters are required")
		return
	}

	year, err := strconv.Atoi(yearStr)
	if err != nil {
		pkgerrors.RespondBadRequest(c, "Invalid year")
		return
	}

	month, err := strconv.Atoi(monthStr)
	if err != nil {
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
// @Param        body  body      models.CreateGroupRequest  true  "Create group request"
// @Success      201   {object}  models.GroupResponse
// @Router       /api/v1/groups [post]
func (h *Handler) CreateGroup(c *gin.Context) {
	jwtUser, ok := getAuthUser(c)
	if !ok {
		return
	}

	var req models.CreateGroupRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		pkgerrors.RespondBadRequest(c, "Request body is missing or has invalid format")
		return
	}

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
// @Success      200      {object}  models.GroupResponse
// @Router       /api/v1/groups/{groupId} [patch]
func (h *Handler) UpdateGroup(c *gin.Context) {
	jwtUser, ok := getAuthUser(c)
	if !ok {
		return
	}

	groupID, err := uuid.Parse(c.Param("groupId"))
	if err != nil {
		pkgerrors.RespondBadRequest(c, "Invalid groupId")
		return
	}

	var updates map[string]any
	if err := c.ShouldBindJSON(&updates); err != nil {
		pkgerrors.RespondBadRequest(c, "Request body is missing or has invalid format")
		return
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
	jwtUser, ok := getAuthUser(c)
	if !ok {
		return
	}

	groupID, err := uuid.Parse(c.Param("groupId"))
	if err != nil {
		pkgerrors.RespondBadRequest(c, "Invalid groupId")
		return
	}

	if err := h.service.DeleteGroup(c.Request.Context(), groupID, jwtUser.ID); err != nil {
		pkgerrors.HandleError(c, err)
		return
	}

	c.Status(http.StatusNoContent)
}
