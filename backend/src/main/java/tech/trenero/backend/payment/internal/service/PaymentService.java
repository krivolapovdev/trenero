package tech.trenero.backend.payment.internal.service;

import jakarta.persistence.EntityNotFoundException;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Lazy;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import tech.trenero.backend.common.response.PaymentResponse;
import tech.trenero.backend.common.security.JwtUser;
import tech.trenero.backend.payment.external.PaymentSpi;
import tech.trenero.backend.payment.internal.entity.Payment;
import tech.trenero.backend.payment.internal.mapper.PaymentMapper;
import tech.trenero.backend.payment.internal.repository.PaymentRepository;
import tech.trenero.backend.payment.internal.request.CreatePaymentRequest;
import tech.trenero.backend.payment.internal.request.UpdatePaymentRequest;
import tech.trenero.backend.student.external.StudentSpi;

@Service
@RequiredArgsConstructor
@Slf4j
public class PaymentService implements PaymentSpi {
  private final PaymentRepository paymentRepository;
  private final PaymentMapper paymentMapper;

  @Lazy private final StudentSpi studentSpi;

  @Transactional(readOnly = true)
  public List<PaymentResponse> getAllPayments(JwtUser jwtUser) {
    log.info("Get payments for user {}", jwtUser.userId());
    return paymentRepository.findAllByOwnerId(jwtUser.userId()).stream()
        .map(paymentMapper::toResponse)
        .toList();
  }

  @Transactional(readOnly = true)
  public PaymentResponse getPaymentById(UUID id, JwtUser jwtUser) {
    log.info("Get status of payment with id {}", id);
    return paymentRepository
        .findByIdAndOwnerId(id, jwtUser.userId())
        .map(paymentMapper::toResponse)
        .orElseThrow(() -> new EntityNotFoundException("Group not found with id=" + id));
  }

  @Transactional(readOnly = true)
  public List<PaymentResponse> getPaymentsByStudentId(UUID studentId, JwtUser jwtUser) {
    log.info("Getting payments by studentId={}", studentId);
    return paymentRepository.findAllByStudentId(studentId, jwtUser.userId()).stream()
        .map(paymentMapper::toResponse)
        .toList();
  }

  @Override
  public Map<UUID, List<PaymentResponse>> getPaymentsByStudentIds(
      List<UUID> studentIds, JwtUser jwtUser) {
    log.info("Getting payments by studentIds {}", studentIds);
    return paymentRepository.findAllByStudentIdsAndOwnerId(studentIds, jwtUser.userId()).stream()
        .map(paymentMapper::toResponse)
        .collect(Collectors.groupingBy(PaymentResponse::studentId));
  }

  @Transactional
  public PaymentResponse createPayment(CreatePaymentRequest request, JwtUser jwtUser) {
    log.info("Creating payment {}", request);

    studentSpi.getStudentById(request.studentId(), jwtUser);

    Payment payment = paymentMapper.toPayment(request, jwtUser.userId());

    Payment savedPayment = savePayment(payment);

    return paymentMapper.toResponse(savedPayment);
  }

  @Transactional
  public PaymentResponse updatePayment(
      UUID paymentId, UpdatePaymentRequest request, JwtUser jwtUser) {
    log.info("Edit payment {}", request);
    return paymentRepository
        .findByIdAndOwnerId(paymentId, jwtUser.userId())
        .map(pay -> paymentMapper.updatePayment(pay, request))
        .map(this::savePayment)
        .map(paymentMapper::toResponse)
        .orElseThrow(
            () -> new EntityNotFoundException("Payment not found with paymentId=" + paymentId));
  }

  @Override
  @Transactional
  public void deletePaymentById(UUID paymentId, JwtUser jwtUser) {
    softDeletePayment(paymentId, jwtUser);
  }

  private void softDeletePayment(UUID paymentId, JwtUser jwtUser) {
    log.info("Deleting payment: {}", paymentId);

    paymentRepository
        .findByIdAndOwnerId(paymentId, jwtUser.userId())
        .map(
            payment -> {
              payment.setDeletedAt(OffsetDateTime.now());
              return savePayment(payment);
            })
        .orElseThrow(
            () -> new EntityNotFoundException("Payment not found with paymentId=" + paymentId));
  }

  private Payment savePayment(Payment payment) {
    log.info("Save payment: {}", payment);
    return paymentRepository.saveAndFlush(payment);
  }
}
