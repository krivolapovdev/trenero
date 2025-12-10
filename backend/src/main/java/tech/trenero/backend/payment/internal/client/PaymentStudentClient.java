package tech.trenero.backend.payment.internal.client;

import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Lazy;
import org.springframework.stereotype.Component;
import tech.trenero.backend.common.security.JwtUser;
import tech.trenero.backend.student.external.StudentSpi;

@Component
@RequiredArgsConstructor
public class PaymentStudentClient {
  @Lazy private final StudentSpi studentSpi;

  public void checkUserOwnsStudent(UUID studentId, JwtUser jwtUser) {
    studentSpi.getStudentById(studentId, jwtUser);
  }
}
