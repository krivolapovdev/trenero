package tech.trenero.backend.payment.internal.spi;

import java.util.List;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import tech.trenero.backend.common.dto.PaymentDto;
import tech.trenero.backend.common.security.JwtUser;
import tech.trenero.backend.payment.external.PaymentSpi;
import tech.trenero.backend.payment.internal.mapper.PaymentMapper;
import tech.trenero.backend.payment.internal.service.PaymentService;

@Component
@RequiredArgsConstructor
@Slf4j
public class PaymentSpiImpl implements PaymentSpi {
  private final PaymentService paymentService;
  private final PaymentMapper paymentMapper;

  @Override
  public List<PaymentDto> getPaymentsByStudentId(UUID studentId, JwtUser jwtUser) {
    if (studentId == null || jwtUser == null) {
      return List.of();
    }

    return paymentService.getPaymentsByStudentId(studentId, jwtUser);
  }
}
