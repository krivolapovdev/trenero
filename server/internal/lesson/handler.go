package lesson

import (
	"context"
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	pkgerrors "github.com/krivolapovdev/trenerio/pkg/errors"
	"github.com/krivolapovdev/trenerio/pkg/models"
	"github.com/krivolapovdev/trenerio/pkg/security"
)

type LessonService interface {
	GetLessonDetailsByID(ctx context.Context, lessonID, ownerID uuid.UUID) (models.LessonDetailsResponse, error)
	CreateLesson(ctx context.Context, req models.CreateLessonRequest, ownerID uuid.UUID) (models.LessonResponse, error)
	UpdateLesson(ctx context.Context, lessonID, ownerID uuid.UUID, req models.UpdateLessonRequest) (models.LessonResponse, error)
	DeleteLesson(ctx context.Context, lessonID, ownerID uuid.UUID) error
}

type Handler struct {
	service LessonService
}

func NewHandler(service LessonService) *Handler {
	return &Handler{
		service: service,
	}
}

func getAuthUser(c *gin.Context) (security.JwtUser, bool) {
	val, exists := c.Get("jwtUser")
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

// GetLessonDetails
// @ID           getLessonDetails
// @Tags         lesson-controller
// @Security     BearerAuth
// @Param        lessonId  path      string  true  "Lesson ID"  Format(uuid)
// @Success      200       {object}  models.LessonDetailsResponse
// @Router       /api/v1/lessons/{lessonId}/details [get]
func (h *Handler) GetLessonDetails(c *gin.Context) {
	jwtUser, ok := getAuthUser(c)
	if !ok {
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
// @Param        body  body      models.CreateLessonRequest  true  "Create lesson request"
// @Success      201   {object}  models.LessonResponse
// @Router       /api/v1/lessons [post]
func (h *Handler) CreateLesson(c *gin.Context) {
	jwtUser, ok := getAuthUser(c)
	if !ok {
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
// @Param        body      body      models.UpdateLessonRequest  true  "Update lesson request"
// @Success      200       {object}  models.LessonResponse
// @Router       /api/v1/lessons/{lessonId} [patch]
func (h *Handler) UpdateLesson(c *gin.Context) {
	jwtUser, ok := getAuthUser(c)
	if !ok {
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
	jwtUser, ok := getAuthUser(c)
	if !ok {
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
