package org.trenero.backend.payment.internal.service;

import static org.trenero.backend.common.exception.ExceptionUtils.entityNotFound;
import static org.trenero.backend.common.exception.ExceptionUtils.entityNotFoundSupplier;

import java.time.LocalDate;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;
import java.util.stream.Collectors;
import java.util.stream.IntStream;
import java.util.stream.Stream;
import lombok.NonNull;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Lazy;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.trenero.backend.common.domain.TransactionType;
import org.trenero.backend.common.response.StudentPaymentResponse;
import org.trenero.backend.common.security.JwtUser;
import org.trenero.backend.payment.external.StudentPaymentSpi;
import org.trenero.backend.payment.internal.domain.StudentPayment;
import org.trenero.backend.payment.internal.domain.Transaction;
import org.trenero.backend.payment.internal.mapper.StudentPaymentMapper;
import org.trenero.backend.payment.internal.repository.StudentPaymentRepository;
import org.trenero.backend.payment.internal.request.CreateStudentPaymentRequest;
import org.trenero.backend.payment.internal.request.UpdatePaymentRequest;
import org.trenero.backend.student.external.StudentSpi;

@Service
@RequiredArgsConstructor
@Slf4j
public class StudentPaymentService implements StudentPaymentSpi {
  private final StudentPaymentRepository studentPaymentRepository;
  private final StudentPaymentMapper paymentMapper;

  @Lazy private final TransactionService transactionService;
  @Lazy private final StudentSpi studentSpi;

  @Transactional(readOnly = true)
  public @NonNull List<StudentPaymentResponse> getAllStudentPayments(@NonNull JwtUser jwtUser) {
    log.info("Getting all student payments: user={}", jwtUser);

    var allPayments = studentPaymentRepository.findAllByOwnerIdSorted(jwtUser.userId());

    return allPayments.stream()
        .collect(Collectors.groupingBy(StudentPayment::getStudentId))
        .values()
        .stream()
        .flatMap(this::toSortedResponseStream)
        .toList();
  }

  @Transactional(readOnly = true)
  public StudentPaymentResponse getStudentPaymentById(UUID paymentId, JwtUser jwtUser) {
    log.info("Getting student payment by paymentId: paymentId={}; user={}", paymentId, jwtUser);

    var payment =
        studentPaymentRepository
            .findByTransactionIdAndOwnerId(paymentId, jwtUser.userId())
            .orElseThrow(entityNotFoundSupplier(StudentPayment.class, paymentId, jwtUser));

    var previousPaidUntil =
        studentPaymentRepository
            .findLatestPaidUntilBeforeDate(payment.getStudentId(), payment.getPaidUntil())
            .orElse(null);

    return paymentMapper.toResponse(payment, payment.getTransaction(), previousPaidUntil);
  }

  @Transactional(readOnly = true)
  public @NonNull List<StudentPaymentResponse> getStudentPaymentsByStudentId(
      @NonNull UUID studentId, @NonNull JwtUser jwtUser) {
    log.info("Getting student payments by student id: studentId={}; user={}", studentId, jwtUser);

    var sortedPayments =
        studentPaymentRepository.findAllByStudentIdAndOwnerIdSorted(studentId, jwtUser.userId());

    return toSortedResponseStream(sortedPayments).toList();
  }

  @Override
  @Transactional(readOnly = true)
  public @NonNull Map<UUID, List<StudentPaymentResponse>> getStudentPaymentsByStudentIds(
      @NonNull List<UUID> studentIds, @NonNull JwtUser jwtUser) {
    log.info(
        "Getting student payments by student ids: studentIds={}; user={}", studentIds, jwtUser);

    var payments =
        studentPaymentRepository.findAllByStudentIdsAndOwnerId(studentIds, jwtUser.userId());

    return payments.stream()
        .collect(Collectors.groupingBy(StudentPayment::getStudentId))
        .entrySet()
        .stream()
        .collect(
            Collectors.toMap(
                Map.Entry::getKey, e -> toSortedResponseStream(e.getValue()).toList()));
  }

  @Transactional
  public StudentPaymentResponse createStudentPayment(
      CreateStudentPaymentRequest request, JwtUser jwtUser) {
    log.info("Creating student payment: request={}; user={}", request, jwtUser);

    studentSpi.getStudentById(request.studentId(), jwtUser);

    Transaction transaction =
        transactionService.createTransactionEntity(
            jwtUser.userId(), request.amount(), TransactionType.INCOME, request.date());

    StudentPayment studentPayment =
        StudentPayment.builder()
            .transaction(transaction)
            .studentId(request.studentId())
            .paidUntil(request.paidUntil())
            .build();

    StudentPayment saved = saveStudentPayment(studentPayment);

    Optional<LocalDate> previousPaidUntil =
        studentPaymentRepository.findLatestPaidUntilByStudentId(request.studentId());

    LocalDate newPaidUntil =
        previousPaidUntil
            .filter(date -> !date.isBefore(request.date()))
            .map(date -> date.plusMonths(1))
            .orElseGet(() -> request.date().plusMonths(1));

    return paymentMapper.toResponse(saved, transaction, newPaidUntil);
  }

  @Transactional
  public StudentPaymentResponse updateStudentPayment(
      UUID paymentId, UpdatePaymentRequest request, JwtUser jwtUser) {
    log.info(
        "Updating student payment: paymentId={}; request={}; user={}", paymentId, request, jwtUser);

    StudentPayment payment =
        studentPaymentRepository
            .findByTransactionIdAndOwnerId(paymentId, jwtUser.userId())
            .orElseThrow(entityNotFoundSupplier(StudentPayment.class, paymentId, jwtUser));

    var updatedTx =
        transactionService.updateTransaction(paymentId, request.amount(), request.date(), jwtUser);

    if (request.paidUntil() != null) {
      payment.setPaidUntil(request.paidUntil());
    }

    StudentPayment saved = saveStudentPayment(payment);

    LocalDate paidFrom =
        studentPaymentRepository
            .findLatestPaidUntilBeforeDate(saved.getStudentId(), saved.getPaidUntil())
            .orElse(null);

    return paymentMapper.toResponse(saved, updatedTx, paidFrom);
  }

  @Override
  @Transactional
  public void deleteStudentPaymentById(@NonNull UUID paymentId, @NonNull JwtUser jwtUser) {
    log.info("Deleting student payment: paymentId={}; user={}", paymentId, jwtUser);

    if (!studentPaymentRepository.existsById(paymentId)) {
      throw entityNotFound(StudentPayment.class, paymentId, jwtUser);
    }

    transactionService.softDeleteTransaction(paymentId, jwtUser);
  }

  private StudentPayment saveStudentPayment(StudentPayment studentPayment) {
    log.info("Saving student payment: studentPayment={}", studentPayment);
    return studentPaymentRepository.saveAndFlush(studentPayment);
  }

  private Stream<StudentPaymentResponse> toSortedResponseStream(List<StudentPayment> paymentsDesc) {
    var safeList =
        paymentsDesc.stream()
            .sorted(Comparator.comparing(StudentPayment::getPaidUntil).reversed())
            .toList();

    return IntStream.range(0, safeList.size())
        .mapToObj(
            i -> {
              var current = paymentsDesc.get(i);
              var paidFrom = i < safeList.size() - 1 ? safeList.get(i + 1).getPaidUntil() : null;
              return paymentMapper.toResponse(current, current.getTransaction(), paidFrom);
            });
  }
}
