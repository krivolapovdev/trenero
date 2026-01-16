package tech.trenero.backend.attendance.external;

import java.util.List;
import java.util.UUID;
import tech.trenero.backend.codegen.types.Attendance;
import tech.trenero.backend.codegen.types.CreateAttendanceInput;
import tech.trenero.backend.common.security.JwtUser;

public interface AttendanceSpi {
  List<Attendance> getAttendancesByStudentId(UUID studentId, JwtUser jwtUser);

  List<Attendance> getAttendancesByLessonId(UUID lessonId, JwtUser jwtUser);

  void createAttendances(
      UUID lessonId,
      UUID groupId,
      List<CreateAttendanceInput> attendanceInputList,
      JwtUser jwtUser);

  void editAttendancesByLessonId(UUID lessonId, List<CreateAttendanceInput> input, JwtUser jwtUser);

  void removeAttendancesByLessonId(UUID lessonId, JwtUser jwtUser);
}
