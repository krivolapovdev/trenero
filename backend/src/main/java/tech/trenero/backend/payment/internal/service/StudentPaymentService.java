package tech.trenero.backend.payment.internal.service;

import jakarta.persistence.EntityNotFoundException;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Lazy;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import tech.trenero.backend.common.domain.TransactionType;
import tech.trenero.backend.common.response.StudentPaymentResponse;
import tech.trenero.backend.common.security.JwtUser;
import tech.trenero.backend.payment.external.StudentPaymentSpi;
import tech.trenero.backend.payment.internal.domain.StudentPayment;
import tech.trenero.backend.payment.internal.domain.Transaction;
import tech.trenero.backend.payment.internal.mapper.StudentPaymentMapper;
import tech.trenero.backend.payment.internal.repository.StudentPaymentRepository;
import tech.trenero.backend.payment.internal.request.CreateStudentPaymentRequest;
import tech.trenero.backend.payment.internal.request.UpdatePaymentRequest;
import tech.trenero.backend.student.external.StudentSpi;

@Service
@RequiredArgsConstructor
@Slf4j
public class StudentPaymentService implements StudentPaymentSpi {
  @Lazy private final StudentPaymentRepository studentPaymentRepository;
  @Lazy private final StudentPaymentMapper paymentMapper;
  @Lazy private final TransactionService transactionService;
  @Lazy private final StudentSpi studentSpi;

  @Transactional(readOnly = true)
  public List<StudentPaymentResponse> getAllStudentPayments(JwtUser jwtUser) {
    log.info("Get all student payments for user {}", jwtUser.userId());
    return studentPaymentRepository.findAllByOwnerId(jwtUser.userId()).stream()
        .map(payment -> paymentMapper.toResponse(payment, payment.getTransaction()))
        .toList();
  }

  @Transactional(readOnly = true)
  public StudentPaymentResponse getStudentPaymentById(UUID id, JwtUser jwtUser) {
    log.info("Get student payment by id {} for user {}", id, jwtUser.userId());
    return studentPaymentRepository
        .findByTransactionIdAndOwnerId(id, jwtUser.userId())
        .map(payment -> paymentMapper.toResponse(payment, payment.getTransaction()))
        .orElseThrow(
            () -> new EntityNotFoundException("Payment not found or access denied: " + id));
  }

  @Transactional(readOnly = true)
  public List<StudentPaymentResponse> getStudentPaymentsByStudentId(
      UUID studentId, JwtUser jwtUser) {
    log.info("Getting student payments by studentId={} for user={}", studentId, jwtUser.userId());
    return studentPaymentRepository
        .findAllByStudentIdAndOwnerId(studentId, jwtUser.userId())
        .stream()
        .map(payment -> paymentMapper.toResponse(payment, payment.getTransaction()))
        .toList();
  }

  @Override
  @Transactional(readOnly = true)
  public Map<UUID, List<StudentPaymentResponse>> getStudentPaymentsByStudentIds(
      List<UUID> studentIds, JwtUser jwtUser) {
    log.info(
        "Getting student payments for studentIds {} for user {}", studentIds, jwtUser.userId());
    return studentPaymentRepository
        .findAllByStudentIdsAndOwnerId(studentIds, jwtUser.userId())
        .stream()
        .map(p -> paymentMapper.toResponse(p, p.getTransaction()))
        .collect(Collectors.groupingBy(StudentPaymentResponse::studentId));
  }

  @Transactional
  public StudentPaymentResponse createStudentPayment(
      CreateStudentPaymentRequest request, JwtUser jwtUser) {
    log.info("Creating student payment for student {}", request.studentId());

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
    log.info("Updating student payment {}", paymentId);

    StudentPayment payment =
        studentPaymentRepository
            .findByTransactionIdAndOwnerId(paymentId, jwtUser.userId())
            .orElseThrow(
                () -> new EntityNotFoundException("Student Payment not found: " + paymentId));

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
  public void deleteStudentPaymentById(UUID paymentId, JwtUser jwtUser) {
    log.info("Deleting student payment: {}", paymentId);

    if (!studentPaymentRepository.existsById(paymentId)) {
      throw new EntityNotFoundException("Payment not found: " + paymentId);
    }

    transactionService.softDeleteTransaction(paymentId, jwtUser);
  }

  private StudentPayment saveStudentPayment(StudentPayment studentPayment) {
    log.info("Save student payment: {}", studentPayment);
    return studentPaymentRepository.saveAndFlush(studentPayment);
  }
}
