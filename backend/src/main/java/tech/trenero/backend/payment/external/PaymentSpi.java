package tech.trenero.backend.payment.external;

import java.util.List;
import java.util.UUID;
import tech.trenero.backend.common.response.PaymentResponse;
import tech.trenero.backend.common.security.JwtUser;

public interface PaymentSpi {
  List<PaymentResponse> getPaymentsByStudentId(UUID studentId, JwtUser jwtUser);

  void deletePaymentById(UUID paymentId, JwtUser jwtUser);
}
