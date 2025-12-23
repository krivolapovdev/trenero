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

@Service
@RequiredArgsConstructor
@Slf4j
public class PaymentGraphQlService {
  private final PaymentRepository paymentRepository;

  public Optional<Payment> getPaymentById(UUID id, JwtUser jwtUser) {
    log.info("Get status of payment with id {}", id);
    return paymentRepository.findByIdAndOwnerId(id, jwtUser.userId());
  }

  @Transactional
  public Payment createPayment(CreatePaymentInput input, JwtUser jwtUser) {
    log.info("Creating payment {}", input);

    Payment payment =
        Payment.builder()
            .studentId(input.studentId())
            .amount(input.amount())
            .ownerId(jwtUser.userId())
            .build();

    return savePayment(payment);
  }

  public Payment savePayment(Payment payment) {
    log.info("Save payment: {}", payment);
    return paymentRepository.save(payment);
  }

  public List<Payment> getPaymentsByStudentId(UUID studentId, JwtUser jwtUser) {
    return paymentRepository.findAllByStudentId(studentId, jwtUser.userId());
  }
}
