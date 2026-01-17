package tech.trenero.backend.student.internal.resolver;

import java.util.List;
import java.util.Optional;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Lazy;
import org.springframework.graphql.data.method.annotation.SchemaMapping;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import tech.trenero.backend.codegen.types.Group;
import tech.trenero.backend.codegen.types.Payment;
import tech.trenero.backend.codegen.types.Student;
import tech.trenero.backend.codegen.types.Visit;
import tech.trenero.backend.common.security.JwtUser;
import tech.trenero.backend.group.external.GroupSpi;
import tech.trenero.backend.payment.external.PaymentSpi;
import tech.trenero.backend.visit.external.VisitSpi;

@Controller
@RequiredArgsConstructor
public class StudentGraphQlResolver {
  @Lazy private final GroupSpi groupSpi;
  @Lazy private final PaymentSpi paymentSpi;
  @Lazy private final VisitSpi visitSpi;

  @SchemaMapping(typeName = "Student", field = "group")
  public Optional<Group> group(Student student, @AuthenticationPrincipal JwtUser jwtUser) {
    return groupSpi.findGroupById(student.getGroup().getId(), jwtUser);
  }

  @SchemaMapping(typeName = "Student", field = "payments")
  public List<Payment> payments(Student student, @AuthenticationPrincipal JwtUser jwtUser) {
    return paymentSpi.getPaymentsByStudentId(student.getId(), jwtUser);
  }

  @SchemaMapping(typeName = "Student", field = "visits")
  public List<Visit> visits(Student student, @AuthenticationPrincipal JwtUser jwtUser) {
    return visitSpi.getVisitsByStudentId(student.getId(), jwtUser);
  }
}
