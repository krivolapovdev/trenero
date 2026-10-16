package errors

import (
	"context"
	"fmt"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/krivolapovdev/trenerio/pkg/logger"
)

type ProblemDetail struct {
	Type      string           `json:"type,omitempty"`
	Title     string           `json:"title"`
	Status    int              `json:"status"`
	Detail    string           `json:"detail"`
	Instance  string           `json:"instance,omitempty"`
	Timestamp string           `json:"timestamp"`
	Code      string           `json:"code,omitempty"`
	Errors    []map[string]any `json:"errors,omitempty"`
}

type ConflictError struct {
	Code    string
	Message string
}

func (e *ConflictError) Error() string {
	return e.Message
}

type NotFoundError struct {
	Entity  string
	ID      uuid.UUID
	OwnerID uuid.UUID
}

func (e *NotFoundError) Error() string {
	return fmt.Sprintf("%s not found with id={%s} for user={%s}", e.Entity, e.ID, e.OwnerID)
}

type BadRequestError struct {
	Message string
}

func (e *BadRequestError) Error() string {
	return e.Message
}

func getContextAndPath(c *gin.Context) (context.Context, string, string) {
	if c == nil || c.Request == nil {
		return context.Background(), "", ""
	}
	return c.Request.Context(), c.Request.RequestURI, c.Request.URL.Path
}

func RespondProblem(c *gin.Context, status int, title, detail string) {
	ctx, uri, path := getContextAndPath(c)
	if status >= 500 {
		logger.ErrorContext(ctx, "HTTP internal server error",
			"status", status,
			"title", title,
			"detail", detail,
			"path", path,
		)
	} else {
		logger.WarnContext(ctx, "HTTP client error",
			"status", status,
			"title", title,
			"detail", detail,
			"path", path,
		)
	}

	c.JSON(status, ProblemDetail{
		Title:     title,
		Status:    status,
		Detail:    detail,
		Instance:  uri,
		Timestamp: time.Now().UTC().Format(time.RFC3339),
	})
}

func RespondConflict(c *gin.Context, code, detail string) {
	ctx, uri, path := getContextAndPath(c)
	logger.WarnContext(ctx, "Conflict",
		"status", http.StatusConflict,
		"code", code,
		"detail", detail,
		"path", path,
	)

	c.JSON(http.StatusConflict, ProblemDetail{
		Title:     "Conflict",
		Status:    http.StatusConflict,
		Detail:    detail,
		Instance:  uri,
		Timestamp: time.Now().UTC().Format(time.RFC3339),
		Code:      code,
	})
}

func RespondNotFound(c *gin.Context, detail string) {
	RespondProblem(c, http.StatusNotFound, "Not Found", detail)
}

func RespondBadRequest(c *gin.Context, detail string) {
	RespondProblem(c, http.StatusBadRequest, "Bad Request", detail)
}

func RespondUnauthorized(c *gin.Context, detail string) {
	if detail == "" {
		detail = "Authentication failed or token is invalid"
	}
	RespondProblem(c, http.StatusUnauthorized, "Unauthorized", detail)
}

func RespondValidationFailed(c *gin.Context, errs []map[string]interface{}) {
	ctx, uri, path := getContextAndPath(c)
	logger.WarnContext(ctx, "Validation Failed",
		"status", http.StatusBadRequest,
		"errors", errs,
		"path", path,
	)

	c.JSON(http.StatusBadRequest, ProblemDetail{
		Title:     "Validation Failed",
		Status:    http.StatusBadRequest,
		Detail:    "One or more fields in the request failed validation",
		Instance:  uri,
		Timestamp: time.Now().UTC().Format(time.RFC3339),
		Errors:    errs,
	})
}

func HandleError(c *gin.Context, err error) {
	if err == nil {
		return
	}
	switch e := err.(type) {
	case *ConflictError:
		RespondConflict(c, e.Code, e.Message)
	case *NotFoundError:
		RespondNotFound(c, e.Error())
	case *BadRequestError:
		RespondBadRequest(c, e.Message)
	default:
		ctx, _, path := getContextAndPath(c)
		logger.ErrorContext(ctx, "Unhandled internal server error",
			"error", err.Error(),
			"path", path,
		)
		RespondProblem(c, http.StatusInternalServerError, "Internal Server Error", "An unexpected error occurred. Please contact support or try again later.")
	}
}
