package org.trenero.backend.payment.internal.service;

import static org.trenero.backend.common.exception.ExceptionUtils.entityNotFoundSupplier;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.UUID;
import lombok.NonNull;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Lazy;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.trenero.backend.common.domain.TransactionType;
import org.trenero.backend.common.security.JwtUser;
import org.trenero.backend.payment.external.TransactionSpi;
import org.trenero.backend.payment.external.response.TransactionResponse;
import org.trenero.backend.payment.internal.domain.StudentPayment;
import org.trenero.backend.payment.internal.domain.Transaction;
import org.trenero.backend.payment.internal.mapper.TransactionMapper;
import org.trenero.backend.payment.internal.repository.TransactionRepository;
import org.trenero.backend.payment.internal.request.CreateTransactionRequest;
import org.trenero.backend.student.external.StudentSpi;

@Service
@RequiredArgsConstructor
@Slf4j
public class TransactionService implements TransactionSpi {

  private final TransactionRepository transactionRepository;
  private final TransactionMapper transactionMapper;
  @Lazy private final StudentSpi studentSpi;

  @Transactional(readOnly = true)
  public Page<TransactionResponse> getPaginatedTransactionsWithStudentPayment(
      int page, int size, @NonNull JwtUser jwtUser) {

    int pageIndex = Math.max(0, page - 1);
    Pageable pageable = PageRequest.of(pageIndex, size, Sort.by(Sort.Direction.DESC, "date"));

    Page<Transaction> transactions =
        transactionRepository.findAllWithStudentPayment(jwtUser.id(), pageable);

    var studentIds =
        transactions.getContent().stream()
            .map(Transaction::getStudentPayment)
            .filter(Objects::nonNull)
            .map(StudentPayment::getStudentId)
            .toList();

    var studentsByIds = studentSpi.getStudentsByIds(studentIds, jwtUser);

    return transactions.map(tx -> transactionMapper.toResponse(tx, studentsByIds));
  }

  @Transactional(readOnly = true)
  public @NonNull TransactionResponse getTransactionById(
      @NonNull UUID transactionId, @NonNull JwtUser jwtUser) {
    log.info("Fetching transactionId={} from database for userId={}", transactionId, jwtUser.id());

    Transaction transaction =
        transactionRepository
            .findByIdAndOwnerId(transactionId, jwtUser.id())
            .orElseThrow(entityNotFoundSupplier(Transaction.class, transactionId, jwtUser));

    return transactionMapper.toResponse(transaction);
  }

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
  public @NonNull TransactionResponse createTransaction(
      @NonNull CreateTransactionRequest request, @NonNull JwtUser jwtUser) {
    log.info("Saving new {} transaction to database for userId={}", request.type(), jwtUser.id());

    Transaction transaction = transactionMapper.toEntity(request, jwtUser.id());
    Transaction savedTransaction = transactionRepository.saveAndFlush(transaction);

    return transactionMapper.toResponse(savedTransaction);
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
  public @NonNull TransactionResponse updateTransaction(
      @NonNull UUID transactionId, @NonNull Map<String, Object> updates, @NonNull JwtUser jwtUser) {
    log.info("Patching transactionId={} in database for userId={}", transactionId, jwtUser.id());

    return transactionRepository
        .findByIdAndOwnerId(transactionId, jwtUser.id())
        .map(transaction -> transactionMapper.updateTransaction(transaction, updates))
        .map(transactionRepository::save)
        .map(transactionMapper::toResponse)
        .orElseThrow(entityNotFoundSupplier(Transaction.class, transactionId, jwtUser));
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
  public void deleteTransaction(@NonNull UUID transactionId, @NonNull JwtUser jwtUser) {
    log.info("Deleting transaction: transactionId={}; user={}", transactionId, jwtUser);

    Transaction transaction =
        transactionRepository
            .findByIdAndOwnerId(transactionId, jwtUser.id())
            .orElseThrow(entityNotFoundSupplier(Transaction.class, transactionId, jwtUser));

    transactionRepository.delete(transaction);
  }

  private @NonNull Transaction saveTransaction(@NonNull Transaction transaction) {
    log.info("Saving transaction: transaction={}", transaction);
    return transactionRepository.saveAndFlush(transaction);
  }
}
