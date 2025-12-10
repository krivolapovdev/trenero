package tech.trenero.backend.payment.internal.service;

import jakarta.persistence.EntityNotFoundException;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import tech.trenero.backend.common.security.JwtUser;
import tech.trenero.backend.payment.internal.client.PaymentStudentClient;
import tech.trenero.backend.payment.internal.entity.Payment;
import tech.trenero.backend.payment.internal.mapper.PaymentMapper;
import tech.trenero.backend.payment.internal.repository.PaymentRepository;
import tech.trenero.backend.payment.internal.request.PaymentRequest;
import tech.trenero.backend.payment.internal.response.PaymentResponse;

@Service
@RequiredArgsConstructor
@Slf4j
public class PaymentService {
  private final PaymentRepository paymentRepository;
  private final PaymentStudentClient studentClient;
  private final PaymentMapper paymentMapper;

  public PaymentResponse getPaymentById(UUID paymentId, JwtUser jwtUser) {
    log.info("Get status of payment with id {}", paymentId);

    var payment =
        paymentRepository
            .findById(paymentId)
            .orElseThrow(
                () -> new EntityNotFoundException("Payment with id " + paymentId + " not found"));

    studentClient.checkUserOwnsStudent(payment.getStudentId(), jwtUser);

    return paymentMapper.toPaymentResponse(payment);
  }

  @Transactional
  public UUID createPayment(PaymentRequest paymentRequest, JwtUser jwtUser) {
    log.info("Creating payment request {}", paymentRequest);

    studentClient.checkUserOwnsStudent(paymentRequest.studentId(), jwtUser);

    Payment payment = paymentMapper.toPayment(paymentRequest);

    Payment savedPayment = savePayment(payment);

    return savedPayment.getId();
  }

  public Payment savePayment(Payment payment) {
    log.info("Save payment: {}", payment);
    return paymentRepository.save(payment);
  }
}
