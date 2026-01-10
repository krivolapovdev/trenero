package tech.trenero.backend.payment.internal.service;

import java.time.OffsetDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import tech.trenero.backend.common.dto.PaymentDto;
import tech.trenero.backend.common.security.JwtUser;
import tech.trenero.backend.payment.internal.entity.Payment;
import tech.trenero.backend.payment.internal.input.CreatePaymentInput;
import tech.trenero.backend.payment.internal.mapper.PaymentMapper;
import tech.trenero.backend.payment.internal.repository.PaymentRepository;
import tech.trenero.backend.student.external.StudentValidator;

@Service
@RequiredArgsConstructor
@Slf4j
public class PaymentService {
  private final PaymentRepository paymentRepository;
  private final PaymentMapper paymentMapper;
  private final StudentValidator studentValidator;

  @Transactional(readOnly = true)
  public List<PaymentDto> getAllPayments(JwtUser jwtUser) {
    log.info("Get payments for user {}", jwtUser.userId());
    return paymentRepository.findAllByOwnerId(jwtUser.userId()).stream()
        .map(paymentMapper::toPaymentDto)
        .toList();
  }

  @Transactional(readOnly = true)
  public Optional<PaymentDto> getPaymentById(UUID id, JwtUser jwtUser) {
    log.info("Get status of payment with id {}", id);
    return paymentRepository
        .findByIdAndOwnerId(id, jwtUser.userId())
        .map(paymentMapper::toPaymentDto);
  }

  @Transactional(readOnly = true)
  public List<PaymentDto> getPaymentsByStudentId(UUID studentId, JwtUser jwtUser) {
    log.info("Getting payments by studentId={}", studentId);
    return paymentRepository.findAllByStudentId(studentId, jwtUser.userId()).stream()
        .map(paymentMapper::toPaymentDto)
        .toList();
  }

  @Transactional
  public PaymentDto createPayment(CreatePaymentInput input, JwtUser jwtUser) {
    log.info("Creating payment {}", input);

    studentValidator.validateStudentIsPresentAndActive(input.studentId(), jwtUser);

    Payment payment = paymentMapper.toPayment(input, jwtUser.userId());

    Payment savedPayment = savePayment(payment);

    return paymentMapper.toPaymentDto(savedPayment);
  }

  @Transactional
  public Optional<PaymentDto> softDeletePayment(UUID id, JwtUser jwtUser) {
    log.info("Deleting payment: {}", id);
    return paymentRepository
        .findByIdAndOwnerId(id, jwtUser.userId())
        .map(
            payment -> {
              payment.setDeletedAt(OffsetDateTime.now());
              return savePayment(payment);
            })
        .map(paymentMapper::toPaymentDto);
  }

  private Payment savePayment(Payment payment) {
    log.info("Save payment: {}", payment);
    return paymentRepository.saveAndFlush(payment);
  }
}
