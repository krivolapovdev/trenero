package tech.trenero.backend.payment.internal.resolver;

import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Lazy;
import org.springframework.graphql.data.method.annotation.SchemaMapping;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import tech.trenero.backend.common.dto.PaymentDto;
import tech.trenero.backend.common.dto.StudentDto;
import tech.trenero.backend.common.security.JwtUser;
import tech.trenero.backend.student.external.StudentSpi;

@Controller
@RequiredArgsConstructor
public class PaymentGraphQlResolver {
  @Lazy private final StudentSpi studentSpi;

  @SchemaMapping(typeName = "Payment", field = "student")
  public StudentDto student(PaymentDto payment, @AuthenticationPrincipal JwtUser jwtUser) {
    return studentSpi
        .getStudentById(payment.studentId(), jwtUser)
        .orElseThrow(EntityNotFoundException::new);
  }
}
