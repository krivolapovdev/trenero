package org.trenero.backend.payment.internal.service;

import static org.trenero.backend.common.exception.ExceptionUtils.entityNotFoundSupplier;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.UUID;
import lombok.NonNull;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.trenero.backend.common.domain.TransactionType;
import org.trenero.backend.common.response.TransactionResponse;
import org.trenero.backend.common.security.JwtUser;
import org.trenero.backend.payment.external.TransactionSpi;
import org.trenero.backend.payment.internal.domain.Transaction;
import org.trenero.backend.payment.internal.mapper.TransactionMapper;
import org.trenero.backend.payment.internal.repository.TransactionRepository;

@Service
@RequiredArgsConstructor
@Slf4j
public class TransactionService implements TransactionSpi {

  private final TransactionRepository transactionRepository;
  private final TransactionMapper transactionMapper;

  @Override
  @Transactional(readOnly = true)
  public @NonNull List<TransactionResponse> getTransactionsByDateRange(
      @NonNull LocalDate startDate, @NonNull LocalDate endDate, @NonNull JwtUser jwtUser) {
    log.info(
        "Getting transactions by date range: user={}; startDate={}; endDate={}",
        jwtUser,
        startDate,
        endDate);

    return transactionRepository
        .findAllByOwnerIdAndDateBetween(jwtUser.id(), startDate, endDate)
        .stream()
        .map(transactionMapper::toResponse)
        .toList();
  }

  @Transactional
  public Transaction createTransactionEntity(
      BigDecimal amount, TransactionType type, LocalDate date, JwtUser jwtUser) {
    log.info(
        "Creating transaction entity:amount={}; type={}; date={}; user={}",
        amount,
        type,
        date,
        jwtUser);

    Transaction transaction =
        Transaction.builder().ownerId(jwtUser.id()).type(type).amount(amount).date(date).build();

    return saveTransaction(transaction);
  }

  @Transactional
  public TransactionResponse updateTransaction(
      UUID transactionId, BigDecimal amount, LocalDate date, JwtUser jwtUser) {
    log.info(
        "Updating transaction: transactionId={}; amount={}; date={}; user={}",
        transactionId,
        amount,
        date,
        jwtUser);

    Transaction transaction =
        transactionRepository
            .findByIdAndOwnerId(transactionId, jwtUser.id())
            .orElseThrow(entityNotFoundSupplier(Transaction.class, transactionId, jwtUser));

    if (amount != null) {
      transaction.setAmount(amount);
    }

    if (date != null) {
      transaction.setDate(date);
    }

    Transaction savedTransaction = saveTransaction(transaction);

    return transactionMapper.toResponse(savedTransaction);
  }

  @Transactional
  public void softDeleteTransaction(UUID transactionId, JwtUser jwtUser) {
    log.info("Deleting transaction: transactionId={}; user={}", transactionId, jwtUser);

    Transaction transaction =
        transactionRepository
            .findByIdAndOwnerId(transactionId, jwtUser.id())
            .orElseThrow(entityNotFoundSupplier(Transaction.class, transactionId, jwtUser));

    transaction.setDeletedAt(OffsetDateTime.now());

    transactionRepository.save(transaction);
  }

  private Transaction saveTransaction(Transaction transaction) {
    log.info("Saving transaction: transaction={}", transaction);
    return transactionRepository.saveAndFlush(transaction);
  }
}
