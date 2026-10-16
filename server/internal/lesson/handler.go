package lesson

import (
	"net/http"

	"github.com/gin-gonic/gin"
	pkgerrors "github.com/krivolapovdev/trenerio/pkg/errors"
	"github.com/krivolapovdev/trenerio/pkg/httputil"
	"github.com/krivolapovdev/trenerio/pkg/models"
)

type Handler struct {
	service Service
}

func NewHandler(service Service) *Handler {
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
// @Success      200       {object}  models.LessonDetailsResponse
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
// @Param        body  body      models.CreateLessonRequest  true  "Create lesson request"
// @Success      201   {object}  models.LessonResponse
// @Router       /api/v1/lessons [post]
func (h *Handler) CreateLesson(c *gin.Context) {
	jwtUser, ok := httputil.GetAuthUser(c)
	if !ok {
		return
	}

	var req models.CreateLessonRequest
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
// @Param        body      body      models.UpdateLessonRequest  true  "Update lesson request"
// @Success      200       {object}  models.LessonResponse
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

	var req models.UpdateLessonRequest
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
