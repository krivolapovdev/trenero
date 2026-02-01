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
import tech.trenero.backend.common.response.TransactionResponse;
import tech.trenero.backend.common.security.JwtUser;
import tech.trenero.backend.payment.external.StudentPaymentSpi;
import tech.trenero.backend.payment.internal.domain.StudentPayment;
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
  @Lazy private final StudentPaymentService self;
  @Lazy private final StudentSpi studentSpi;

  @Transactional(readOnly = true)
  public List<StudentPaymentResponse> getAllPayments(JwtUser jwtUser) {
    log.info("Get payments for user {}", jwtUser.userId());

    List<TransactionResponse> transactions = transactionService.getAllTransactions(jwtUser);

    if (transactions.isEmpty()) {
      return List.of();
    }

    List<UUID> txIds = transactions.stream().map(TransactionResponse::id).toList();

    Map<UUID, StudentPayment> paymentMap =
        studentPaymentRepository.findAllByTransactionIds(txIds).stream()
            .collect(Collectors.toMap(StudentPayment::getTransactionId, p -> p));

    return transactions.stream()
        .filter(tx -> paymentMap.containsKey(tx.id()))
        .map(tx -> paymentMapper.toResponse(paymentMap.get(tx.id()), tx))
        .toList();
  }

  @Transactional(readOnly = true)
  public StudentPaymentResponse getPaymentById(UUID id, JwtUser jwtUser) {
    log.info("Get status of payment with id {}", id);

    var transaction = transactionService.getTransactionById(id, jwtUser);

    StudentPayment payment =
        studentPaymentRepository
            .findById(id)
            .orElseThrow(
                () -> new EntityNotFoundException("Student payment record not found for id=" + id));

    return paymentMapper.toResponse(payment, transaction);
  }

  @Transactional(readOnly = true)
  public List<StudentPaymentResponse> getPaymentsByStudentId(UUID studentId, JwtUser jwtUser) {
    log.info("Getting payments by studentId={}", studentId);

    List<StudentPayment> payments = studentPaymentRepository.findAllByStudentId(studentId);

    return payments.stream()
        .map(
            payment -> {
              var tx = transactionService.getTransactionById(payment.getTransactionId(), jwtUser);
              return paymentMapper.toResponse(payment, tx);
            })
        .toList();
  }

  @Override
  @Transactional(readOnly = true)
  public Map<UUID, List<StudentPaymentResponse>> getPaymentsByStudentIds(
      List<UUID> studentIds, JwtUser jwtUser) {
    log.info("Getting payments by studentIds {}", studentIds);

    List<StudentPayment> payments = studentPaymentRepository.findAllByStudentIds(studentIds);
    if (payments.isEmpty()) {
      return Map.of();
    }

    List<UUID> txIds = payments.stream().map(StudentPayment::getTransactionId).toList();

    Map<UUID, TransactionResponse> txMap = transactionService.getTransactionsByIds(txIds, jwtUser);

    return payments.stream()
        .filter(p -> txMap.containsKey(p.getTransactionId()))
        .map(p -> paymentMapper.toResponse(p, txMap.get(p.getTransactionId())))
        .collect(Collectors.groupingBy(StudentPaymentResponse::studentId));
  }

  @Transactional
  public StudentPaymentResponse createPayment(
      CreateStudentPaymentRequest request, JwtUser jwtUser) {
    log.info("Creating payment {}", request);

    studentSpi.getStudentById(request.studentId(), jwtUser);

    var transactionResponse =
        transactionService.createTransaction(
            jwtUser.userId(), request.amount(), TransactionType.INCOME, request.date());

    StudentPayment studentPayment =
        StudentPayment.builder()
            .transactionId(transactionResponse.id())
            .studentId(request.studentId())
            .paidLessons(request.paidLessons())
            .build();

    StudentPayment savedStudentPayment = savePayment(studentPayment);

    return paymentMapper.toResponse(savedStudentPayment);
  }

  @Transactional
  public StudentPaymentResponse updatePayment(
      UUID paymentId, UpdatePaymentRequest request, JwtUser jwtUser) {
    log.info("Updating payment {}", paymentId);

    StudentPayment payment =
        studentPaymentRepository
            .findByTransactionIdAndTransactionOwnerId(paymentId, jwtUser.userId())
            .orElseThrow(() -> new EntityNotFoundException("Payment not found: " + paymentId));

    transactionService.updateTransaction(paymentId, request.amount(), request.date(), jwtUser);

    payment.setPaidLessons(request.paidLessons());

    StudentPayment saved = studentPaymentRepository.save(payment);

    return paymentMapper.toResponse(saved);
  }

  @Override
  @Transactional
  public void deletePaymentById(UUID paymentId, JwtUser jwtUser) {
    log.info("Deleting student payment: {}", paymentId);

    if (!studentPaymentRepository.existsById(paymentId)) {
      throw new EntityNotFoundException("Payment not found: " + paymentId);
    }

    transactionService.softDeleteTransaction(paymentId, jwtUser);
  }

  private StudentPayment savePayment(StudentPayment studentPayment) {
    log.info("Save payment: {}", studentPayment);
    return studentPaymentRepository.saveAndFlush(studentPayment);
  }
}
