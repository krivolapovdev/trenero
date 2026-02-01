package tech.trenero.backend.payment.external;

import java.util.List;
import java.util.Map;
import java.util.UUID;
import tech.trenero.backend.common.response.StudentPaymentResponse;
import tech.trenero.backend.common.security.JwtUser;

public interface StudentPaymentSpi {
  List<StudentPaymentResponse> getAllStudentPayments(JwtUser jwtUser);

  List<StudentPaymentResponse> getStudentPaymentsByStudentId(UUID studentId, JwtUser jwtUser);

  Map<UUID, List<StudentPaymentResponse>> getStudentPaymentsByStudentIds(
      List<UUID> studentIds, JwtUser jwtUser);

  void deleteStudentPaymentById(UUID paymentId, JwtUser jwtUser);
}
