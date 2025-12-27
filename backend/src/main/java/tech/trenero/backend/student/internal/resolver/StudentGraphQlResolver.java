package tech.trenero.backend.student.internal.resolver;

import java.util.List;
import java.util.Optional;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Lazy;
import org.springframework.graphql.data.method.annotation.SchemaMapping;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import tech.trenero.backend.attendance.external.AttendanceSpi;
import tech.trenero.backend.common.dto.AttendanceDto;
import tech.trenero.backend.common.dto.GroupDto;
import tech.trenero.backend.common.dto.PaymentDto;
import tech.trenero.backend.common.dto.StudentDto;
import tech.trenero.backend.common.security.JwtUser;
import tech.trenero.backend.group.external.GroupSpi;
import tech.trenero.backend.payment.external.PaymentSpi;

@Controller
@RequiredArgsConstructor
public class StudentGraphQlResolver {
  @Lazy private final GroupSpi groupSpi;
  @Lazy private final PaymentSpi paymentSpi;
  @Lazy private final AttendanceSpi attendanceSpi;

  @SchemaMapping(typeName = "Student", field = "group")
  public Optional<GroupDto> group(StudentDto student, @AuthenticationPrincipal JwtUser jwtUser) {
    return groupSpi.getGroupById(student.groupId(), jwtUser);
  }

  @SchemaMapping(typeName = "Student", field = "lastAttendance")
  public Optional<AttendanceDto> lastAttendance(
      StudentDto student, @AuthenticationPrincipal JwtUser jwtUser) {
    return attendanceSpi.getLastStudentAttendance(student.id(), student.groupId(), jwtUser);
  }

  @SchemaMapping(typeName = "Student", field = "payments")
  public List<PaymentDto> payments(StudentDto student, @AuthenticationPrincipal JwtUser jwtUser) {
    return paymentSpi.getPaymentsByStudentId(student.id(), jwtUser);
  }

  @SchemaMapping(typeName = "Student", field = "attendances")
  public List<AttendanceDto> attendances(
      StudentDto student, @AuthenticationPrincipal JwtUser jwtUser) {
    return attendanceSpi.getAttendancesByStudentId(student.id(), jwtUser);
  }
}
