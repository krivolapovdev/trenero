package org.trenero.backend.payment.internal.service;

import static org.trenero.backend.common.exception.ExceptionUtils.entityNotFoundSupplier;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.function.Function;
import java.util.stream.Collectors;
import lombok.NonNull;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Lazy;
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

  @Lazy private final TransactionService self;

  @Transactional(readOnly = true)
  public @NonNull List<TransactionResponse> getAllTransactions(@NonNull JwtUser jwtUser) {
    log.info("Getting all transactions: user={}", jwtUser);
    return transactionRepository.findAllByOwnerId(jwtUser.userId()).stream()
        .map(transactionMapper::toResponse)
        .toList();
  }

  @Transactional(readOnly = true)
  public TransactionResponse getTransactionById(UUID transactionId, JwtUser jwtUser) {
    log.info("Getting transaction by id: transactionId={}; user={}", transactionId, jwtUser);
    return transactionRepository
        .findByIdAndOwnerId(transactionId, jwtUser.userId())
        .map(transactionMapper::toResponse)
        .orElseThrow(entityNotFoundSupplier(Transaction.class, transactionId, jwtUser));
  }

  @Transactional(readOnly = true)
  public Map<UUID, TransactionResponse> getTransactionsByIds(List<UUID> ids, JwtUser jwtUser) {
    log.info("Getting transactions by ids: ids={}; user={}", ids, jwtUser);
    return transactionRepository.findAllByIdInAndOwnerId(ids, jwtUser.userId()).stream()
        .map(transactionMapper::toResponse)
        .collect(Collectors.toMap(TransactionResponse::id, Function.identity()));
  }

  @Transactional
  public Transaction createTransactionEntity(
      UUID ownerId, BigDecimal amount, TransactionType type, LocalDate date) {
    log.info(
        "Creating transaction entity: ownerId={}; amount={}; type={}; date={}",
        ownerId,
        amount,
        type,
        date);

    Transaction transaction =
        Transaction.builder().ownerId(ownerId).type(type).amount(amount).date(date).build();

    return saveTransaction(transaction);
  }

  @Transactional
  public TransactionResponse createTransaction(
      UUID ownerId, BigDecimal amount, TransactionType type, LocalDate date) {
    Transaction saved = self.createTransactionEntity(ownerId, amount, type, date);
    return transactionMapper.toResponse(saved);
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
            .findByIdAndOwnerId(transactionId, jwtUser.userId())
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
            .findByIdAndOwnerId(transactionId, jwtUser.userId())
            .orElseThrow(entityNotFoundSupplier(Transaction.class, transactionId, jwtUser));

    transaction.setDeletedAt(OffsetDateTime.now());

    transactionRepository.save(transaction);
  }

  private Transaction saveTransaction(Transaction transaction) {
    log.info("Saving transaction: transaction={}", transaction);
    return transactionRepository.saveAndFlush(transaction);
  }
}
