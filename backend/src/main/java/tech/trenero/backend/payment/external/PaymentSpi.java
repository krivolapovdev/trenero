package tech.trenero.backend.payment.external;

import java.util.List;
import java.util.Map;
import java.util.UUID;
import tech.trenero.backend.common.response.PaymentResponse;
import tech.trenero.backend.common.security.JwtUser;

public interface PaymentSpi {
  List<PaymentResponse> getAllPayments(JwtUser jwtUser);

  List<PaymentResponse> getPaymentsByStudentId(UUID studentId, JwtUser jwtUser);

  Map<UUID, List<PaymentResponse>> getPaymentsByStudentIds(List<UUID> studentIds, JwtUser jwtUser);

  void deletePaymentById(UUID paymentId, JwtUser jwtUser);
}
