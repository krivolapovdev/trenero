package lesson

import (
	"context"
	"github.com/krivolapovdev/trenerio/pkg/request"
	"github.com/krivolapovdev/trenerio/pkg/response"
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	pkgerrors "github.com/krivolapovdev/trenerio/pkg/errors"
	httputil "github.com/krivolapovdev/trenerio/pkg/utils"
)

type lessonService interface {
	GetLessonDetailsByID(ctx context.Context, lessonID, ownerID uuid.UUID) (response.LessonDetailsResponse, error)
	CreateLesson(ctx context.Context, req request.CreateLessonRequest, ownerID uuid.UUID) (response.LessonResponse, error)
	UpdateLesson(ctx context.Context, lessonID, ownerID uuid.UUID, req request.UpdateLessonRequest) (response.LessonResponse, error)
	DeleteLesson(ctx context.Context, lessonID, ownerID uuid.UUID) error
}

type Handler struct {
	service lessonService
}

func NewHandler(service lessonService) *Handler {
	return &Handler{
		service: service,
	}
}

// RegisterRoutes registers the lesson routes onto the given router group.
func (h *Handler) RegisterRoutes(rg *gin.RouterGroup) {
	lessons := rg.Group("/lessons")
	{
		lessons.GET("/:lessonId/details", h.GetLessonDetails)
		lessons.POST("", h.CreateLesson)
		lessons.PATCH("/:lessonId", h.UpdateLesson)
		lessons.DELETE("/:lessonId", h.DeleteLesson)
	}
}

// GetLessonDetails
// @ID           getLessonDetails
// @Tags         lesson-controller
// @Security     BearerAuth
// @Param        lessonId  path      string  true  "Lesson ID"  Format(uuid)
// @Success      200       {object}  response.LessonDetailsResponse
// @Router       /api/v1/lessons/{lessonId}/details [get]
func (h *Handler) GetLessonDetails(c *gin.Context) {
	jwtUser, ok := httputil.GetAuthUser(c)
	if !ok {
		return
	}

	lessonID, ok := httputil.ParseUUIDParam(c, "lessonId")
	if !ok {
		return
	}

	details, err := h.service.GetLessonDetailsByID(c.Request.Context(), lessonID, jwtUser.ID)
	if err != nil {
		pkgerrors.HandleError(c, err)
		return
	}

	c.JSON(http.StatusOK, details)
}

// CreateLesson
// @ID           createLesson
// @Tags         lesson-controller
// @Security     BearerAuth
// @Param        body  body      request.CreateLessonRequest  true  "Create lesson request"
// @Success      201   {object}  response.LessonResponse
// @Router       /api/v1/lessons [post]
func (h *Handler) CreateLesson(c *gin.Context) {
	jwtUser, ok := httputil.GetAuthUser(c)
	if !ok {
		return
	}

	var req request.CreateLessonRequest
	if !httputil.BindJSON(c, &req) {
		return
	}

	createdLesson, err := h.service.CreateLesson(c.Request.Context(), req, jwtUser.ID)
	if err != nil {
		pkgerrors.HandleError(c, err)
		return
	}

	c.JSON(http.StatusCreated, createdLesson)
}

// UpdateLesson
// @ID           updateLesson
// @Tags         lesson-controller
// @Security     BearerAuth
// @Param        lessonId  path      string                      true  "Lesson ID"              Format(uuid)
// @Param        body      body      request.UpdateLessonRequest  true  "Update lesson request"
// @Success      200       {object}  response.LessonResponse
// @Router       /api/v1/lessons/{lessonId} [patch]
func (h *Handler) UpdateLesson(c *gin.Context) {
	jwtUser, ok := httputil.GetAuthUser(c)
	if !ok {
		return
	}

	lessonID, ok := httputil.ParseUUIDParam(c, "lessonId")
	if !ok {
		return
	}

	var req request.UpdateLessonRequest
	if !httputil.BindJSON(c, &req) {
		return
	}

	updatedLesson, err := h.service.UpdateLesson(c.Request.Context(), lessonID, jwtUser.ID, req)
	if err != nil {
		pkgerrors.HandleError(c, err)
		return
	}

	c.JSON(http.StatusOK, updatedLesson)
}

// DeleteLesson
// @ID           deleteLesson
// @Tags         lesson-controller
// @Security     BearerAuth
// @Param        lessonId  path  string  true  "Lesson ID"  Format(uuid)
// @Success      204       "No Content"
// @Router       /api/v1/lessons/{lessonId} [delete]
func (h *Handler) DeleteLesson(c *gin.Context) {
	jwtUser, ok := httputil.GetAuthUser(c)
	if !ok {
		return
	}

	lessonID, ok := httputil.ParseUUIDParam(c, "lessonId")
	if !ok {
		return
	}

	if err := h.service.DeleteLesson(c.Request.Context(), lessonID, jwtUser.ID); err != nil {
		pkgerrors.HandleError(c, err)
		return
	}

	c.Status(http.StatusNoContent)
}
