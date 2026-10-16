package transaction

import (
	"net/http"
	"strconv"

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

// GetPaginatedTransactions
// @ID           getPaginatedTransactions
// @Tags         transaction-controller
// @Security     BearerAuth
// @Param        page  query     int  false  "Page number (1-indexed)"  default(1)
// @Param        size  query     int  false  "Page size"                default(20)
// @Success      200   {object}  models.PageTransactionResponse
// @Router       /api/v1/transactions [get]
func (h *Handler) GetPaginatedTransactions(c *gin.Context) {
	jwtUser, ok := c.MustGet("jwtUser").(security.JwtUser)
	if !ok {
		pkgerrors.RespondUnauthorized(c, "")
		return
	}

	page := 1
	if p := c.Query("page"); p != "" {
		if val, err := strconv.Atoi(p); err == nil {
			page = val
		}
	}

	size := 20
	if s := c.Query("size"); s != "" {
		if val, err := strconv.Atoi(s); err == nil {
			size = val
		}
	}

	resp, err := h.service.GetPaginatedTransactions(c.Request.Context(), page, size, jwtUser.ID)
	if err != nil {
		pkgerrors.HandleError(c, err)
		return
	}

	c.JSON(http.StatusOK, resp)
}

// CreateTransaction
// @ID           createTransaction
// @Tags         transaction-controller
// @Security     BearerAuth
// @Param        body  body      models.CreateTransactionRequest  true  "Create transaction request"
// @Success      201   {object}  models.TransactionResponse
// @Router       /api/v1/transactions [post]
func (h *Handler) CreateTransaction(c *gin.Context) {
	jwtUser, ok := c.MustGet("jwtUser").(security.JwtUser)
	if !ok {
		pkgerrors.RespondUnauthorized(c, "")
		return
	}

	var req models.CreateTransactionRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		pkgerrors.RespondBadRequest(c, "Request body is missing or has invalid format")
		return
	}

	resp, err := h.service.CreateTransaction(c.Request.Context(), req, jwtUser.ID)
	if err != nil {
		pkgerrors.HandleError(c, err)
		return
	}

	c.JSON(http.StatusCreated, resp)
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
	jwtUser, ok := c.MustGet("jwtUser").(security.JwtUser)
	if !ok {
		pkgerrors.RespondUnauthorized(c, "")
		return
	}

	txID, err := uuid.Parse(c.Param("transactionId"))
	if err != nil {
		pkgerrors.RespondBadRequest(c, "Invalid transactionId")
		return
	}

	var updates map[string]interface{}
	if err := c.ShouldBindJSON(&updates); err != nil {
		pkgerrors.RespondBadRequest(c, "Request body is missing or has invalid format")
		return
	}

	resp, err := h.service.UpdateTransaction(c.Request.Context(), txID, jwtUser.ID, updates)
	if err != nil {
		pkgerrors.HandleError(c, err)
		return
	}

	c.JSON(http.StatusOK, resp)
}

// DeleteTransaction
// @ID           deleteTransaction
// @Tags         transaction-controller
// @Security     BearerAuth
// @Param        transactionId  path  string  true  "Transaction ID"  Format(uuid)
// @Success      204            "No Content"
// @Router       /api/v1/transactions/{transactionId} [delete]
func (h *Handler) DeleteTransaction(c *gin.Context) {
	jwtUser, ok := c.MustGet("jwtUser").(security.JwtUser)
	if !ok {
		pkgerrors.RespondUnauthorized(c, "")
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
