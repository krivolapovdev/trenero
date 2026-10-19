package transaction

import (
	"context"
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/krivolapovdev/trenerio/internal/auth"
	pkgerrors "github.com/krivolapovdev/trenerio/internal/shared/errors"
	"github.com/krivolapovdev/trenerio/internal/shared/web"
)

type transactionService interface {
	GetPaginatedTransactions(ctx context.Context, page, size int, ownerID uuid.UUID) (PageTransactionResponse, error)
	CreateTransaction(ctx context.Context, req CreateTransactionRequest, ownerID uuid.UUID) (TransactionResponse, error)
	UpdateTransaction(ctx context.Context, transactionID, ownerID uuid.UUID, updates map[string]any) (TransactionResponse, error)
	DeleteTransaction(ctx context.Context, transactionID, ownerID uuid.UUID) error
}

type Handler struct {
	service transactionService
}

func NewHandler(service transactionService) *Handler {
	return &Handler{
		service: service,
	}
}

// RegisterRoutes registers the transaction routes onto the given router group.
func (h *Handler) RegisterRoutes(rg *gin.RouterGroup) {
	txGroup := rg.Group("/transactions")
	{
		txGroup.GET("", h.GetPaginatedTransactions)
		txGroup.POST("", h.CreateTransaction)
		txGroup.PATCH("/:transactionId", h.UpdateTransaction)
		txGroup.DELETE("/:transactionId", h.DeleteTransaction)
	}
}

// GetPaginatedTransactions
// @ID           getPaginatedTransactions
// @Tags         transaction-controller
// @Security     BearerAuth
// @Param        page  query     int  false  "Page number (1-indexed)"  default(1)
// @Param        size  query     int  false  "Page size"                default(20)
// @Success      200   {object}  response.PageTransactionResponse
// @Router       /api/v1/transactions [get]
func (h *Handler) GetPaginatedTransactions(c *gin.Context) {
	jwtUser, ok := auth.GetUserFromContext(c)
	if !ok {
		return
	}

	page, size := web.ParsePagination(c, 1, 20)

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
// @Param        body  body      request.CreateTransactionRequest  true  "Create transaction request"
// @Success      201   {object}  response.TransactionResponse
// @Router       /api/v1/transactions [post]
func (h *Handler) CreateTransaction(c *gin.Context) {
	jwtUser, ok := auth.GetUserFromContext(c)
	if !ok {
		return
	}

	var req CreateTransactionRequest
	if !web.BindJSON(c, &req) {
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
// @Success      200            {object}  response.TransactionResponse
// @Router       /api/v1/transactions/{transactionId} [patch]
func (h *Handler) UpdateTransaction(c *gin.Context) {
	jwtUser, ok := auth.GetUserFromContext(c)
	if !ok {
		return
	}

	txID, ok := web.ParseUUIDParam(c, "transactionId")
	if !ok {
		return
	}

	var updates map[string]any
	if !web.BindJSON(c, &updates) {
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
	jwtUser, ok := auth.GetUserFromContext(c)
	if !ok {
		return
	}

	txID, ok := web.ParseUUIDParam(c, "transactionId")
	if !ok {
		return
	}

	if err := h.service.DeleteTransaction(c.Request.Context(), txID, jwtUser.ID); err != nil {
		pkgerrors.HandleError(c, err)
		return
	}

	c.Status(http.StatusNoContent)
}
