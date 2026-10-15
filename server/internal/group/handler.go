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
)

type GroupHandler struct {
	service *GroupService
}

func NewGroupHandler(service *GroupService) *GroupHandler {
	return &GroupHandler{
		service: service,
	}
}

func (h *GroupHandler) GetAllGroupsSummary(c *gin.Context) {
	jwtUser, ok := c.MustGet("jwtUser").(security.JwtUser)
	if !ok {
		pkgerrors.RespondUnauthorized(c, "")
		return
	}

	resp, err := h.service.GetAllGroupsSummary(c.Request.Context(), jwtUser.ID)
	if err != nil {
		pkgerrors.HandleError(c, err)
		return
	}

	c.JSON(http.StatusOK, resp)
}

func (h *GroupHandler) GetGroupStudents(c *gin.Context) {
	jwtUser, ok := c.MustGet("jwtUser").(security.JwtUser)
	if !ok {
		pkgerrors.RespondUnauthorized(c, "")
		return
	}

	groupID, err := uuid.Parse(c.Param("groupId"))
	if err != nil {
		pkgerrors.RespondBadRequest(c, "Invalid groupId")
		return
	}

	resp, err := h.service.GetGroupStudents(c.Request.Context(), groupID, jwtUser.ID)
	if err != nil {
		pkgerrors.HandleError(c, err)
		return
	}

	c.JSON(http.StatusOK, resp)
}

func (h *GroupHandler) GetGroupLessons(c *gin.Context) {
	jwtUser, ok := c.MustGet("jwtUser").(security.JwtUser)
	if !ok {
		pkgerrors.RespondUnauthorized(c, "")
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

	from, err := time.Parse(time.RFC3339Nano, fromStr)
	if err != nil {
		from, err = time.Parse(time.RFC3339, fromStr)
		if err != nil {
			pkgerrors.RespondBadRequest(c, "Invalid from date format")
			return
		}
	}

	to, err := time.Parse(time.RFC3339Nano, toStr)
	if err != nil {
		to, err = time.Parse(time.RFC3339, toStr)
		if err != nil {
			pkgerrors.RespondBadRequest(c, "Invalid to date format")
			return
		}
	}

	resp, err := h.service.GetGroupLessons(c.Request.Context(), groupID, jwtUser.ID, from, to)
	if err != nil {
		pkgerrors.HandleError(c, err)
		return
	}

	c.JSON(http.StatusOK, resp)
}

func (h *GroupHandler) GetGroupReport(c *gin.Context) {
	jwtUser, ok := c.MustGet("jwtUser").(security.JwtUser)
	if !ok {
		pkgerrors.RespondUnauthorized(c, "")
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

	resp, err := h.service.GetGroupReport(c.Request.Context(), groupID, jwtUser.ID, year, month)
	if err != nil {
		pkgerrors.HandleError(c, err)
		return
	}

	c.JSON(http.StatusOK, resp)
}

func (h *GroupHandler) CreateGroup(c *gin.Context) {
	jwtUser, ok := c.MustGet("jwtUser").(security.JwtUser)
	if !ok {
		pkgerrors.RespondUnauthorized(c, "")
		return
	}

	var req models.CreateGroupRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		pkgerrors.RespondBadRequest(c, "Request body is missing or has invalid format")
		return
	}

	resp, err := h.service.CreateGroup(c.Request.Context(), req, jwtUser.ID)
	if err != nil {
		pkgerrors.HandleError(c, err)
		return
	}

	c.JSON(http.StatusCreated, resp)
}

func (h *GroupHandler) UpdateGroup(c *gin.Context) {
	jwtUser, ok := c.MustGet("jwtUser").(security.JwtUser)
	if !ok {
		pkgerrors.RespondUnauthorized(c, "")
		return
	}

	groupID, err := uuid.Parse(c.Param("groupId"))
	if err != nil {
		pkgerrors.RespondBadRequest(c, "Invalid groupId")
		return
	}

	var updates map[string]interface{}
	if err := c.ShouldBindJSON(&updates); err != nil {
		pkgerrors.RespondBadRequest(c, "Request body is missing or has invalid format")
		return
	}

	resp, err := h.service.UpdateGroup(c.Request.Context(), groupID, jwtUser.ID, updates)
	if err != nil {
		pkgerrors.HandleError(c, err)
		return
	}

	c.JSON(http.StatusOK, resp)
}

func (h *GroupHandler) DeleteGroup(c *gin.Context) {
	jwtUser, ok := c.MustGet("jwtUser").(security.JwtUser)
	if !ok {
		pkgerrors.RespondUnauthorized(c, "")
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
