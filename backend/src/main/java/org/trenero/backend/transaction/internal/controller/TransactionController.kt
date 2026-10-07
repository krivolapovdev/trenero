package org.trenero.backend.transaction.internal.controller

import jakarta.validation.Valid
import java.util.UUID
import org.springframework.data.domain.Page
import org.springframework.http.HttpStatus
import org.springframework.security.access.prepost.PreAuthorize
import org.springframework.security.core.annotation.AuthenticationPrincipal
import org.springframework.web.bind.annotation.DeleteMapping
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PatchMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RequestParam
import org.springframework.web.bind.annotation.ResponseStatus
import org.springframework.web.bind.annotation.RestController
import org.trenero.backend.common.security.JwtUser
import org.trenero.backend.transaction.external.response.TransactionResponse
import org.trenero.backend.transaction.internal.request.CreateTransactionRequest
import org.trenero.backend.transaction.internal.service.TransactionService

@RestController
@RequestMapping("/api/v1/transactions")
class TransactionController(private val transactionService: TransactionService) {

  @GetMapping
  @PreAuthorize("isAuthenticated()")
  fun getPaginatedTransactions(
    @RequestParam(defaultValue = "1") page: Int,
    @RequestParam(defaultValue = "20") size: Int,
    @AuthenticationPrincipal jwtUser: JwtUser,
  ): Page<TransactionResponse> = transactionService.getPaginatedTransactions(page, size, jwtUser)

  @GetMapping("/{transactionId}")
  @PreAuthorize("isAuthenticated()")
  fun getTransactionById(
    @PathVariable transactionId: UUID,
    @AuthenticationPrincipal jwtUser: JwtUser,
  ): TransactionResponse = transactionService.getTransactionById(transactionId, jwtUser)

  @PostMapping
  @ResponseStatus(HttpStatus.CREATED)
  @PreAuthorize("isAuthenticated()")
  fun createTransaction(
    @Valid @RequestBody request: CreateTransactionRequest,
    @AuthenticationPrincipal jwtUser: JwtUser,
  ): TransactionResponse = transactionService.createTransaction(request, jwtUser)

  @PatchMapping("/{transactionId}")
  @PreAuthorize("isAuthenticated()")
  fun updateTransaction(
    @PathVariable transactionId: UUID,
    @RequestBody @Valid updates: Map<String, Any?>,
    @AuthenticationPrincipal jwtUser: JwtUser,
  ): TransactionResponse = transactionService.updateTransaction(transactionId, updates, jwtUser)

  @DeleteMapping("/{transactionId}")
  @ResponseStatus(HttpStatus.NO_CONTENT)
  @PreAuthorize("isAuthenticated()")
  fun deleteTransaction(
    @PathVariable transactionId: UUID,
    @AuthenticationPrincipal jwtUser: JwtUser,
  ) = transactionService.deleteTransaction(transactionId, jwtUser)
}
