package tech.trenero.backend.payment.internal.service;

import jakarta.persistence.EntityNotFoundException;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.function.Function;
import java.util.stream.Collectors;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Lazy;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import tech.trenero.backend.common.domain.TransactionType;
import tech.trenero.backend.common.response.TransactionResponse;
import tech.trenero.backend.common.security.JwtUser;
import tech.trenero.backend.payment.internal.domain.Transaction;
import tech.trenero.backend.payment.internal.mapper.TransactionMapper;
import tech.trenero.backend.payment.internal.repository.TransactionRepository;

@Service
@RequiredArgsConstructor
@Slf4j
public class TransactionService {
  @Lazy private final TransactionRepository transactionRepository;
  @Lazy private final TransactionMapper transactionMapper;
  @Lazy private final TransactionService self;

  @Transactional(readOnly = true)
  public List<TransactionResponse> getAllTransactions(JwtUser jwtUser) {
    log.info("Getting all transactions for ownerId={}", jwtUser.userId());
    return transactionRepository.findAllByOwnerId(jwtUser.userId()).stream()
        .map(transactionMapper::toResponse)
        .toList();
  }

  @Transactional(readOnly = true)
  public TransactionResponse getTransactionById(UUID transactionId, JwtUser jwtUser) {
    log.info("Getting transaction by id={} for ownerId={}", transactionId, jwtUser.userId());
    return transactionRepository
        .findByIdAndOwnerId(transactionId, jwtUser.userId())
        .map(transactionMapper::toResponse)
        .orElseThrow(() -> new EntityNotFoundException("Transaction not found or access denied"));
  }

  @Transactional(readOnly = true)
  public Map<UUID, TransactionResponse> getTransactionsByIds(List<UUID> ids, JwtUser jwtUser) {
    log.info("Getting transactions by ids for ownerId={}", jwtUser.userId());
    return transactionRepository.findAllByIdInAndOwnerId(ids, jwtUser.userId()).stream()
        .map(transactionMapper::toResponse)
        .collect(Collectors.toMap(TransactionResponse::id, Function.identity()));
  }

  @Transactional
  public TransactionResponse createTransaction(
      UUID ownerId, BigDecimal amount, TransactionType type, LocalDate date) {
    log.info("Creating transaction for ownerId={} amount={} type={}", ownerId, amount, type);

    Transaction transaction =
        Transaction.builder().ownerId(ownerId).type(type).amount(amount).date(date).build();

    Transaction savedTransaction = saveTransaction(transaction);

    return transactionMapper.toResponse(savedTransaction);
  }

  @Transactional
  public TransactionResponse updateTransaction(
      UUID transactionId, BigDecimal amount, LocalDate date, JwtUser jwtUser) {
    log.info("Updating transaction {}: amount={}, date={}", transactionId, amount, date);

    Transaction transaction =
        transactionRepository
            .findByIdAndOwnerId(transactionId, jwtUser.userId())
            .orElseThrow(
                () ->
                    new EntityNotFoundException("Transaction not found with id=" + transactionId));

    transaction.setAmount(amount);
    transaction.setDate(date);

    log.info("Updated transaction {}: amount={}, date={}", transactionId, amount, date);

    Transaction savedTransaction = saveTransaction(transaction);

    return transactionMapper.toResponse(savedTransaction);
  }

  @Transactional
  public void softDeleteTransaction(UUID transactionId, JwtUser jwtUser) {
    log.info("Soft deleting transaction {}", transactionId);

    Transaction transaction =
        transactionRepository
            .findByIdAndOwnerId(transactionId, jwtUser.userId())
            .orElseThrow(
                () ->
                    new EntityNotFoundException("Transaction not found with id=" + transactionId));

    transaction.setDeletedAt(OffsetDateTime.now());

    log.info("Soft deleted transaction {}", transactionId);

    transactionRepository.save(transaction);
  }

  private Transaction saveTransaction(Transaction transaction) {
    log.info("Save transaction: {}", transaction);
    return transactionRepository.saveAndFlush(transaction);
  }
}
