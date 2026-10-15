package errors

import (
	"fmt"
	"log"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

type ProblemDetail struct {
	Type      string                   `json:"type,omitempty"`
	Title     string                   `json:"title"`
	Status    int                      `json:"status"`
	Detail    string                   `json:"detail"`
	Instance  string                   `json:"instance,omitempty"`
	Timestamp string                   `json:"timestamp"`
	Code      string                   `json:"code,omitempty"`
	Errors    []map[string]interface{} `json:"errors,omitempty"`
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

func RespondProblem(c *gin.Context, status int, title, detail string) {
	if status >= 500 {
		log.Printf("[ERROR] %d %s: %s", status, title, detail)
	}
	c.JSON(status, ProblemDetail{
		Title:     title,
		Status:    status,
		Detail:    detail,
		Instance:  c.Request.RequestURI,
		Timestamp: time.Now().UTC().Format(time.RFC3339Nano),
	})
}

func RespondConflict(c *gin.Context, code, detail string) {
	c.JSON(http.StatusConflict, ProblemDetail{
		Title:     "Conflict",
		Status:    http.StatusConflict,
		Detail:    detail,
		Instance:  c.Request.RequestURI,
		Timestamp: time.Now().UTC().Format(time.RFC3339Nano),
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
	c.JSON(http.StatusBadRequest, ProblemDetail{
		Title:     "Validation Failed",
		Status:    http.StatusBadRequest,
		Detail:    "One or more fields in the request failed validation",
		Instance:  c.Request.RequestURI,
		Timestamp: time.Now().UTC().Format(time.RFC3339Nano),
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
		log.Printf("[ERROR] Unhandled error: %v", err)
		RespondProblem(c, http.StatusInternalServerError, "Internal Server Error", "An unexpected error occurred. Please contact support or try again later.")
	}
}
