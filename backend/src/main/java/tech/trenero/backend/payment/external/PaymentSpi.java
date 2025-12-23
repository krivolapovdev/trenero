package tech.trenero.backend.payment.external;

import java.util.List;
import java.util.UUID;
import tech.trenero.backend.common.dto.PaymentDto;
import tech.trenero.backend.common.security.JwtUser;

public interface PaymentSpi {
  List<PaymentDto> getPaymentsByStudentId(UUID studentId, JwtUser jwtUser);
}
