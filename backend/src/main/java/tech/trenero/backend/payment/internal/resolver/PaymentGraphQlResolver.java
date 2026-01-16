package tech.trenero.backend.payment.internal.resolver;

import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Lazy;
import org.springframework.graphql.data.method.annotation.SchemaMapping;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import tech.trenero.backend.codegen.types.Payment;
import tech.trenero.backend.codegen.types.Student;
import tech.trenero.backend.common.security.JwtUser;
import tech.trenero.backend.student.external.StudentSpi;

@Controller
@RequiredArgsConstructor
public class PaymentGraphQlResolver {
  @Lazy private final StudentSpi studentSpi;

  @SchemaMapping(typeName = "Payment", field = "student")
  public Student student(Payment payment, @AuthenticationPrincipal JwtUser jwtUser) {
    UUID studentId = payment.getStudent().getId();
    return studentSpi.getStudentById(studentId, jwtUser);
  }
}
