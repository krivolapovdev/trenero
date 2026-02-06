package org.trenero.backend.payment.internal.service;

import static org.trenero.backend.common.exception.ExceptionUtils.entityNotFound;
import static org.trenero.backend.common.exception.ExceptionUtils.entityNotFoundSupplier;

import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;
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
    return studentPaymentRepository.findAllByOwnerId(jwtUser.userId()).stream()
        .map(payment -> paymentMapper.toResponse(payment, payment.getTransaction()))
        .toList();
  }

  @Transactional(readOnly = true)
  public StudentPaymentResponse getStudentPaymentById(UUID paymentId, JwtUser jwtUser) {
    log.info("Getting student payment by paymentId: paymentId={}; user={}", paymentId, jwtUser);
    return studentPaymentRepository
        .findByTransactionIdAndOwnerId(paymentId, jwtUser.userId())
        .map(payment -> paymentMapper.toResponse(payment, payment.getTransaction()))
        .orElseThrow(entityNotFoundSupplier(StudentPayment.class, paymentId, jwtUser));
  }

  @Transactional(readOnly = true)
  public @NonNull List<StudentPaymentResponse> getStudentPaymentsByStudentId(
      @NonNull UUID studentId, @NonNull JwtUser jwtUser) {
    log.info("Getting student payments by student id: studentId={}; user={}", studentId, jwtUser);
    return studentPaymentRepository
        .findAllByStudentIdAndOwnerId(studentId, jwtUser.userId())
        .stream()
        .map(payment -> paymentMapper.toResponse(payment, payment.getTransaction()))
        .toList();
  }

  @Override
  @Transactional(readOnly = true)
  public @NonNull Map<UUID, List<StudentPaymentResponse>> getStudentPaymentsByStudentIds(
      @NonNull List<UUID> studentIds, @NonNull JwtUser jwtUser) {
    log.info(
        "Getting student payments by student ids: studentIds={}; user={}", studentIds, jwtUser);
    return studentPaymentRepository
        .findAllByStudentIdsAndOwnerId(studentIds, jwtUser.userId())
        .stream()
        .map(p -> paymentMapper.toResponse(p, p.getTransaction()))
        .collect(Collectors.groupingBy(StudentPaymentResponse::studentId));
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
            .paidLessons(request.paidLessons())
            .build();

    StudentPayment saved = saveStudentPayment(studentPayment);

    return paymentMapper.toResponse(saved, transaction);
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

    if (request.paidLessons() != null) {
      payment.setPaidLessons(request.paidLessons());
    }

    StudentPayment saved = saveStudentPayment(payment);

    return paymentMapper.toResponse(saved, updatedTx);
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
}
