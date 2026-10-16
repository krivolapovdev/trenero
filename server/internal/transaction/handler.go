package transaction

import (
	"net/http"
	"strconv"

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

// GetPaginatedTransactions
// @ID           getPaginatedTransactions
// @Tags         transaction-controller
// @Security     BearerAuth
// @Param        page  query     int  false  "Page number (1-indexed)"  default(1)
// @Param        size  query     int  false  "Page size"                default(20)
// @Success      200   {object}  models.PageTransactionResponse
// @Router       /api/v1/transactions [get]
func (h *Handler) GetPaginatedTransactions(c *gin.Context) {
	jwtUser, ok := getAuthUser(c)
	if !ok {
		return
	}

	page := 1
	if pageStr := c.Query("page"); pageStr != "" {
		if val, err := strconv.Atoi(pageStr); err == nil {
			page = val
		}
	}

	size := 20
	if sizeStr := c.Query("size"); sizeStr != "" {
		if val, err := strconv.Atoi(sizeStr); err == nil {
			size = val
		}
	}

	pageResponse, err := h.service.GetPaginatedTransactions(c.Request.Context(), page, size, jwtUser.ID)
	if err != nil {
		pkgerrors.HandleError(c, err)
		return
	}

	c.JSON(http.StatusOK, pageResponse)
}

// CreateTransaction
// @ID           createTransaction
// @Tags         transaction-controller
// @Security     BearerAuth
// @Param        body  body      models.CreateTransactionRequest  true  "Create transaction request"
// @Success      201   {object}  models.TransactionResponse
// @Router       /api/v1/transactions [post]
func (h *Handler) CreateTransaction(c *gin.Context) {
	jwtUser, ok := getAuthUser(c)
	if !ok {
		return
	}

	var req models.CreateTransactionRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		pkgerrors.RespondBadRequest(c, "Request body is missing or has invalid format")
		return
	}

	createdTx, err := h.service.CreateTransaction(c.Request.Context(), req, jwtUser.ID)
	if err != nil {
		pkgerrors.HandleError(c, err)
		return
	}

	c.JSON(http.StatusCreated, createdTx)
}

// UpdateTransaction
// @ID           updateTransaction
// @Tags         transaction-controller
// @Security     BearerAuth
// @Param        transactionId  path      string             true  "Transaction ID"    Format(uuid)
// @Param        body           body      map[string]object  true  "Fields to update"
// @Success      200            {object}  models.TransactionResponse
// @Router       /api/v1/transactions/{transactionId} [patch]
func (h *Handler) UpdateTransaction(c *gin.Context) {
	jwtUser, ok := getAuthUser(c)
	if !ok {
		return
	}

	txID, err := uuid.Parse(c.Param("transactionId"))
	if err != nil {
		pkgerrors.RespondBadRequest(c, "Invalid transactionId")
		return
	}

	var updates map[string]any
	if err := c.ShouldBindJSON(&updates); err != nil {
		pkgerrors.RespondBadRequest(c, "Request body is missing or has invalid format")
		return
	}

	updatedTx, err := h.service.UpdateTransaction(c.Request.Context(), txID, jwtUser.ID, updates)
	if err != nil {
		pkgerrors.HandleError(c, err)
		return
	}

	c.JSON(http.StatusOK, updatedTx)
}

// DeleteTransaction
// @ID           deleteTransaction
// @Tags         transaction-controller
// @Security     BearerAuth
// @Param        transactionId  path  string  true  "Transaction ID"  Format(uuid)
// @Success      204            "No Content"
// @Router       /api/v1/transactions/{transactionId} [delete]
func (h *Handler) DeleteTransaction(c *gin.Context) {
	jwtUser, ok := getAuthUser(c)
	if !ok {
		return
	}

	txID, err := uuid.Parse(c.Param("transactionId"))
	if err != nil {
		pkgerrors.RespondBadRequest(c, "Invalid transactionId")
		return
	}

	if err := h.service.DeleteTransaction(c.Request.Context(), txID, jwtUser.ID); err != nil {
		pkgerrors.HandleError(c, err)
		return
	}

	c.Status(http.StatusNoContent)
}
