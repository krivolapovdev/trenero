package tech.trenero.backend.payment.internal.spi;

import java.util.List;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import tech.trenero.backend.common.dto.PaymentDto;
import tech.trenero.backend.common.security.JwtUser;
import tech.trenero.backend.payment.external.PaymentSpi;
import tech.trenero.backend.payment.internal.mapper.PaymentMapper;
import tech.trenero.backend.payment.internal.service.PaymentGraphQlService;

@Service
@RequiredArgsConstructor
@Slf4j
public class PaymentSpiImpl implements PaymentSpi {
  private final PaymentGraphQlService paymentGraphQlService;
  private final PaymentMapper paymentMapper;

  @Override
  public List<PaymentDto> getPaymentsByStudentId(UUID studentId, JwtUser jwtUser) {
    return paymentGraphQlService.getPaymentsByStudentId(studentId, jwtUser).stream()
        .map(paymentMapper::toPaymentDto)
        .toList();
  }
}
