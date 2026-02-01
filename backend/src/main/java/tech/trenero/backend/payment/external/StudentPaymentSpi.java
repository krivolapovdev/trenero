package tech.trenero.backend.payment.external;

import java.util.List;
import java.util.Map;
import java.util.UUID;
import tech.trenero.backend.common.response.StudentPaymentResponse;
import tech.trenero.backend.common.security.JwtUser;

public interface StudentPaymentSpi {
  List<StudentPaymentResponse> getAllPayments(JwtUser jwtUser);

  List<StudentPaymentResponse> getPaymentsByStudentId(UUID studentId, JwtUser jwtUser);

  Map<UUID, List<StudentPaymentResponse>> getPaymentsByStudentIds(
      List<UUID> studentIds, JwtUser jwtUser);

  void deletePaymentById(UUID paymentId, JwtUser jwtUser);
}
