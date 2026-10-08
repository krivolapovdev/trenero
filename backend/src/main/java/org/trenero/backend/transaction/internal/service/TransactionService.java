package org.trenero.backend.transaction.internal.service;

import static org.trenero.backend.common.exception.ExceptionUtils.entityNotFoundSupplier;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.UUID;
import java.util.stream.Collectors;
import lombok.NonNull;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Lazy;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;
import org.trenero.backend.common.domain.TransactionType;
import org.trenero.backend.common.security.JwtUser;
import org.trenero.backend.student.external.spi.StudentSpi;
import org.trenero.backend.transaction.external.response.TransactionResponse;
import org.trenero.backend.transaction.external.spi.TransactionSpi;
import org.trenero.backend.transaction.internal.domain.StudentPayment;
import org.trenero.backend.transaction.internal.domain.Transaction;
import org.trenero.backend.transaction.internal.mapper.TransactionMapper;
import org.trenero.backend.transaction.internal.repository.StudentPaymentRepository;
import org.trenero.backend.transaction.internal.repository.TransactionRepository;
import org.trenero.backend.transaction.internal.request.CreateStudentPaymentDetailsRequest;
import org.trenero.backend.transaction.internal.request.CreateTransactionRequest;

@Service
@RequiredArgsConstructor
@Slf4j
public class TransactionService implements TransactionSpi {

  private final TransactionRepository transactionRepository;
  private final StudentPaymentRepository studentPaymentRepository;
  private final TransactionMapper transactionMapper;
  @Lazy private final StudentSpi studentSpi;

  @Transactional(readOnly = true)
  public Page<TransactionResponse> getPaginatedTransactions(
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

  @Override
  @Transactional(readOnly = true)
  public @NonNull List<TransactionResponse> getTransactionsByStudentId(
      @NonNull UUID studentId, @NonNull JwtUser jwtUser) {
    log.info("Getting transactions by studentId: studentId={}; user={}", studentId, jwtUser.id());

    var studentPayments =
        studentPaymentRepository.findAllByStudentIdAndOwnerIdSorted(studentId, jwtUser.id());

    return studentPayments.stream()
        .map(StudentPayment::getTransaction)
        .filter(Objects::nonNull)
        .map(transactionMapper::toResponse)
        .toList();
  }

  @Override
  @Transactional(readOnly = true)
  public @NonNull Map<UUID, List<TransactionResponse>> getTransactionsByStudentIds(
      @NonNull List<UUID> studentIds, @NonNull JwtUser jwtUser) {
    log.info(
        "Getting transactions by studentIds: studentIds={}; user={}", studentIds, jwtUser.id());

    var studentPayments =
        studentPaymentRepository.findAllByStudentIdsAndOwnerId(studentIds, jwtUser.id());

    return studentPayments.stream()
        .filter(sp -> sp.getTransaction() != null)
        .collect(
            Collectors.groupingBy(
                StudentPayment::getStudentId,
                Collectors.mapping(
                    sp -> transactionMapper.toResponse(sp.getTransaction()), Collectors.toList())));
  }

  @Transactional
  public @NonNull TransactionResponse createTransaction(
      @NonNull CreateTransactionRequest request, @NonNull JwtUser jwtUser) {
    log.info(
        "Saving new {} transaction to database for userId={}", request.getType(), jwtUser.id());

    if (request.getPaymentDetails() instanceof CreateStudentPaymentDetailsRequest studentDetails) {
      studentSpi.getStudentById(studentDetails.getStudentId(), jwtUser);
    }

    Transaction transaction = transactionMapper.toEntity(request, jwtUser.id());

    if (transaction.getStudentPayment() != null) {
      transaction.getStudentPayment().setTransaction(transaction);
    }

    Transaction savedTransaction = transactionRepository.save(transaction);

    if (savedTransaction.getStudentPayment() != null) {
      studentPaymentRepository.saveAndFlush(savedTransaction.getStudentPayment());
    }

    transactionRepository.flush();

    return transactionMapper.toResponse(savedTransaction);
  }

  @Override
  @Transactional
  public @NonNull TransactionResponse createStudentPayment(
      @NonNull UUID studentId,
      @NonNull BigDecimal amount,
      @NonNull LocalDate date,
      @NonNull LocalDate paidUntil,
      @NonNull JwtUser jwtUser) {
    log.info(
        "Saving new student payment to database: studentId={}; user={}", studentId, jwtUser.id());

    studentSpi.getStudentById(studentId, jwtUser);

    if (paidUntil.isBefore(date)) {
      throw new ResponseStatusException(
          HttpStatus.BAD_REQUEST, "paidUntil must not be before the payment date");
    }

    Transaction transaction =
        Transaction.builder()
            .ownerId(jwtUser.id())
            .type(TransactionType.INCOME)
            .amount(amount)
            .date(date)
            .build();

    Transaction savedTransaction = transactionRepository.saveAndFlush(transaction);

    StudentPayment studentPayment =
        StudentPayment.builder()
            .studentId(studentId)
            .paidUntil(paidUntil)
            .transaction(savedTransaction)
            .build();

    studentPaymentRepository.saveAndFlush(studentPayment);
    savedTransaction.setStudentPayment(studentPayment);

    return transactionMapper.toResponse(savedTransaction);
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
  public void deleteTransaction(@NonNull UUID transactionId, @NonNull JwtUser jwtUser) {
    log.info("Deleting transaction: transactionId={}; user={}", transactionId, jwtUser.id());

    Transaction transaction =
        transactionRepository
            .findByIdAndOwnerId(transactionId, jwtUser.id())
            .orElseThrow(entityNotFoundSupplier(Transaction.class, transactionId, jwtUser));

    StudentPayment studentPayment = transaction.getStudentPayment();
    if (studentPayment != null) {
      transaction.setStudentPayment(null);
      studentPaymentRepository.delete(studentPayment);
      studentPaymentRepository.flush();
    }

    transactionRepository.delete(transaction);
  }

  @Override
  @Transactional
  public void deleteTransactionById(@NonNull UUID transactionId, @NonNull JwtUser jwtUser) {
    deleteTransaction(transactionId, jwtUser);
  }
}
