package tech.trenero.backend.attendance.internal.spi;

import java.util.List;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;
import tech.trenero.backend.attendance.external.AttendanceSpi;
import tech.trenero.backend.attendance.internal.service.AttendanceService;
import tech.trenero.backend.common.dto.AttendanceDto;
import tech.trenero.backend.common.security.JwtUser;

@Component
@RequiredArgsConstructor
public class AttendanceSpiImpl implements AttendanceSpi {
  private final AttendanceService attendanceService;

  @Override
  public List<AttendanceDto> getAttendancesByStudentId(UUID studentId, JwtUser jwtUser) {
    return attendanceService.getAttendancesByStudentId(studentId, jwtUser);
  }

  @Override
  public List<AttendanceDto> getAttendancesByLessonId(UUID lessonId, JwtUser jwtUser) {
    return attendanceService.getAttendancesByLessonId(lessonId, jwtUser);
  }
}
