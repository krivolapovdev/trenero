package tech.trenero.backend.attendance.internal.controller;

import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import tech.trenero.backend.attendance.internal.request.LessonRequest;
import tech.trenero.backend.attendance.internal.service.AttendanceService;
import tech.trenero.backend.common.security.JwtUser;

@RestController
@RequestMapping("/api/v1/attendance")
@RequiredArgsConstructor
@Validated
public class AttendanceController {
  private final AttendanceService attendanceService;

  @PostMapping("/lesson")
  public UUID recordAttendance(
      @RequestBody LessonRequest lessonRequest, @AuthenticationPrincipal JwtUser jwtUser) {
    return attendanceService.recordAttendance(lessonRequest, jwtUser);
  }
}
