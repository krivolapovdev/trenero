package lesson

import (
	"net/http"

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

// GetLessonDetails
// @ID           getLessonDetails
// @Tags         lesson-controller
// @Security     BearerAuth
// @Param        lessonId  path      string  true  "Lesson ID"  Format(uuid)
// @Success      200       {object}  models.LessonDetailsResponse
// @Router       /api/v1/lessons/{lessonId}/details [get]
func (h *Handler) GetLessonDetails(c *gin.Context) {
	jwtUser, ok := c.MustGet("jwtUser").(security.JwtUser)
	if !ok {
		pkgerrors.RespondUnauthorized(c, "")
		return
	}

	lessonID, err := uuid.Parse(c.Param("lessonId"))
	if err != nil {
		pkgerrors.RespondBadRequest(c, "Invalid lessonId")
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
// @Param        request  body      models.CreateLessonRequest  true  "Create lesson request"
// @Success      201      {object}  models.LessonResponse
// @Router       /api/v1/lessons [post]
func (h *Handler) CreateLesson(c *gin.Context) {
	jwtUser, ok := c.MustGet("jwtUser").(security.JwtUser)
	if !ok {
		pkgerrors.RespondUnauthorized(c, "")
		return
	}

	var req models.CreateLessonRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		pkgerrors.RespondBadRequest(c, "Request body is missing or has invalid format")
		return
	}

	created, err := h.service.CreateLesson(c.Request.Context(), req, jwtUser.ID)
	if err != nil {
		pkgerrors.HandleError(c, err)
		return
	}

	c.JSON(http.StatusCreated, created)
}

// UpdateLesson
// @ID           updateLesson
// @Tags         lesson-controller
// @Security     BearerAuth
// @Param        lessonId  path      string                      true  "Lesson ID"              Format(uuid)
// @Param        request   body      models.UpdateLessonRequest  true  "Update lesson request"
// @Success      200       {object}  models.LessonResponse
// @Router       /api/v1/lessons/{lessonId} [patch]
func (h *Handler) UpdateLesson(c *gin.Context) {
	jwtUser, ok := c.MustGet("jwtUser").(security.JwtUser)
	if !ok {
		pkgerrors.RespondUnauthorized(c, "")
		return
	}

	lessonID, err := uuid.Parse(c.Param("lessonId"))
	if err != nil {
		pkgerrors.RespondBadRequest(c, "Invalid lessonId")
		return
	}

	var req models.UpdateLessonRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		pkgerrors.RespondBadRequest(c, "Request body is missing or has invalid format")
		return
	}

	updated, err := h.service.UpdateLesson(c.Request.Context(), lessonID, jwtUser.ID, req)
	if err != nil {
		pkgerrors.HandleError(c, err)
		return
	}

	c.JSON(http.StatusOK, updated)
}

// DeleteLesson
// @ID           deleteLesson
// @Tags         lesson-controller
// @Security     BearerAuth
// @Param        lessonId  path  string  true  "Lesson ID"  Format(uuid)
// @Success      204       "No Content"
// @Router       /api/v1/lessons/{lessonId} [delete]
func (h *Handler) DeleteLesson(c *gin.Context) {
	jwtUser, ok := c.MustGet("jwtUser").(security.JwtUser)
	if !ok {
		pkgerrors.RespondUnauthorized(c, "")
		return
	}

	lessonID, err := uuid.Parse(c.Param("lessonId"))
	if err != nil {
		pkgerrors.RespondBadRequest(c, "Invalid lessonId")
		return
	}

	if err := h.service.DeleteLesson(c.Request.Context(), lessonID, jwtUser.ID); err != nil {
		pkgerrors.HandleError(c, err)
		return
	}

	c.Status(http.StatusNoContent)
}
