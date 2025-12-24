package tech.trenero.backend.payment.internal.service;

import java.util.List;
import java.util.Optional;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import tech.trenero.backend.common.security.JwtUser;
import tech.trenero.backend.payment.internal.entity.Payment;
import tech.trenero.backend.payment.internal.input.CreatePaymentInput;
import tech.trenero.backend.payment.internal.repository.PaymentRepository;
import tech.trenero.backend.student.external.StudentValidator;

@Service
@RequiredArgsConstructor
@Slf4j
public class PaymentService {
  private final PaymentRepository paymentRepository;
  private final StudentValidator studentValidator;

  public List<Payment> getAllPayments(JwtUser jwtUser) {
    return paymentRepository.findAllByOwnerId(jwtUser.userId());
  }

  public Optional<Payment> getPaymentById(UUID id, JwtUser jwtUser) {
    log.info("Get status of payment with id {}", id);
    return paymentRepository.findByIdAndOwnerId(id, jwtUser.userId());
  }

  public List<Payment> getPaymentsByStudentId(UUID studentId, JwtUser jwtUser) {
    log.info("Getting payments by studentId={}", studentId);
    return paymentRepository.findAllByStudentId(studentId, jwtUser.userId());
  }

  @Transactional
  public Payment createPayment(CreatePaymentInput input, JwtUser jwtUser) {
    log.info("Creating payment {}", input);

    studentValidator.validateStudentIsPresentAndActive(input.studentId(), jwtUser);

    Payment payment =
        Payment.builder()
            .studentId(input.studentId())
            .amount(input.amount())
            .ownerId(jwtUser.userId())
            .build();

    return savePayment(payment);
  }

  @Transactional
  public Payment savePayment(Payment payment) {
    log.info("Save payment: {}", payment);
    return paymentRepository.save(payment);
  }

  @Transactional
  public Optional<Payment> softDeletePayment(UUID id, JwtUser jwtUser) {
    log.info("Deleting payment: {}", id);
    return getPaymentById(id, jwtUser)
        .map(
            payment -> {
              payment.setDeleted(true);
              return savePayment(payment);
            });
  }
}
