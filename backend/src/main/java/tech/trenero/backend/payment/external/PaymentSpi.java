package tech.trenero.backend.payment.external;

import java.util.List;
import java.util.UUID;
import tech.trenero.backend.codegen.types.Payment;
import tech.trenero.backend.common.security.JwtUser;

public interface PaymentSpi {
  List<Payment> getPaymentsByStudentId(UUID studentId, JwtUser jwtUser);
}
