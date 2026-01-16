package tech.trenero.backend.payment.internal.spi;

import java.util.List;
import java.util.Objects;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import tech.trenero.backend.codegen.types.Payment;
import tech.trenero.backend.common.security.JwtUser;
import tech.trenero.backend.payment.external.PaymentSpi;
import tech.trenero.backend.payment.internal.service.PaymentService;

@Component
@RequiredArgsConstructor
@Slf4j
public class PaymentSpiImpl implements PaymentSpi {
  private final PaymentService paymentService;

  @Override
  public List<Payment> getPaymentsByStudentId(UUID studentId, JwtUser jwtUser) {
    Objects.requireNonNull(studentId, "studentId must not be null");
    Objects.requireNonNull(jwtUser, "jwtUser must not be null");

    return paymentService.getPaymentsByStudentId(studentId, jwtUser);
  }
}
