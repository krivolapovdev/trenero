package tech.trenero.backend.attendance.external;

import java.util.List;
import java.util.Optional;
import java.util.UUID;
import tech.trenero.backend.common.dto.AttendanceDto;
import tech.trenero.backend.common.security.JwtUser;

public interface AttendanceSpi {
  Optional<AttendanceDto> getLastStudentAttendance(UUID studentId, UUID groupId, JwtUser jwtUser);

  List<AttendanceDto> getAttendancesByStudentId(UUID studentId, JwtUser jwtUser);

  List<AttendanceDto> getAttendancesByLessonId(UUID lessonId, JwtUser jwtUser);
}
