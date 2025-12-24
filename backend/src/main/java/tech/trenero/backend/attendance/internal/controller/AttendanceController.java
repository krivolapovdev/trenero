package tech.trenero.backend.attendance.internal.controller;

import jakarta.validation.Valid;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.graphql.data.method.annotation.Argument;
import org.springframework.graphql.data.method.annotation.MutationMapping;
import org.springframework.graphql.data.method.annotation.QueryMapping;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.validation.annotation.Validated;
import tech.trenero.backend.attendance.internal.input.CreateAttendanceInput;
import tech.trenero.backend.attendance.internal.service.AttendanceService;
import tech.trenero.backend.common.dto.AttendanceDto;
import tech.trenero.backend.common.security.JwtUser;

@Controller
@RequiredArgsConstructor
@Validated
public class AttendanceController {
  private final AttendanceService attendanceService;

  @QueryMapping
  @PreAuthorize("isAuthenticated()")
  public List<AttendanceDto> attendances(@AuthenticationPrincipal JwtUser jwtUser) {
    return attendanceService.getAllAttendances(jwtUser);
  }

  @QueryMapping
  @PreAuthorize("isAuthenticated()")
  public Optional<AttendanceDto> attendance(
      @Argument("id") UUID id, @AuthenticationPrincipal JwtUser jwtUser) {
    return attendanceService.getAttendanceById(id, jwtUser);
  }

  @MutationMapping
  @PreAuthorize("isAuthenticated()")
  public AttendanceDto createAttendance(
      @Argument("input") @Valid CreateAttendanceInput input,
      @AuthenticationPrincipal JwtUser jwtUser) {
    return attendanceService.createAttendance(input, jwtUser);
  }

  @MutationMapping
  @PreAuthorize("isAuthenticated()")
  public Optional<AttendanceDto> deleteAttendance(
      @Argument("id") UUID id, @AuthenticationPrincipal JwtUser jwtUser) {
    return attendanceService.softDeleteAttendance(id, jwtUser);
  }
}
