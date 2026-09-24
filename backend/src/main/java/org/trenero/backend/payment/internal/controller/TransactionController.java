package org.trenero.backend.payment.internal.controller;

import jakarta.validation.Valid;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import lombok.NonNull;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;
import org.trenero.backend.common.response.TransactionResponse;
import org.trenero.backend.common.security.JwtUser;
import org.trenero.backend.payment.internal.request.CreateTransactionRequest;
import org.trenero.backend.payment.internal.service.TransactionService;

@RestController
@RequestMapping("/api/v1/transactions")
@RequiredArgsConstructor
@Slf4j
public class TransactionController {

  private final TransactionService transactionService;

  @GetMapping
  public @NonNull List<TransactionResponse> getAllTransactions(
      @AuthenticationPrincipal @NonNull JwtUser jwtUser) {
    log.info("Fetching all transactions for userId={}", jwtUser.id());
    return transactionService.getAllTransactions(jwtUser);
  }

  @GetMapping("/{transactionId}")
  public @NonNull TransactionResponse getTransactionById(
      @PathVariable @NonNull UUID transactionId,
      @AuthenticationPrincipal @NonNull JwtUser jwtUser) {
    log.info("Fetching transactionId={} for userId={}", transactionId, jwtUser.id());
    return transactionService.getTransactionById(transactionId, jwtUser);
  }

  @PostMapping
  @ResponseStatus(HttpStatus.CREATED)
  public @NonNull TransactionResponse createTransaction(
      @Valid @RequestBody @NonNull CreateTransactionRequest request,
      @AuthenticationPrincipal @NonNull JwtUser jwtUser) {
    log.info("Creating new {} transaction for userId={}", request.type(), jwtUser.id());
    return transactionService.createTransaction(request, jwtUser);
  }

  @PatchMapping("/{transactionId}")
  public @NonNull TransactionResponse updateTransaction(
      @PathVariable @NonNull UUID transactionId,
      @RequestBody @Valid Map<String, Object> updates,
      @AuthenticationPrincipal @NonNull JwtUser jwtUser) {
    log.info("Updating transactionId={} for userId={}", transactionId, jwtUser.id());
    return transactionService.updateTransaction(transactionId, updates, jwtUser);
  }

  @DeleteMapping("/{transactionId}")
  @ResponseStatus(HttpStatus.NO_CONTENT)
  public void deleteTransaction(
      @PathVariable @NonNull UUID transactionId,
      @AuthenticationPrincipal @NonNull JwtUser jwtUser) {
    log.info("Deleting transactionId={} for userId={}", transactionId, jwtUser.id());
    transactionService.deleteTransaction(transactionId, jwtUser);
  }
}
