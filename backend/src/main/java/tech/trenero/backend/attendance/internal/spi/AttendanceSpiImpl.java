package tech.trenero.backend.attendance.internal.spi;

import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.UUID;
import java.util.function.Function;
import java.util.stream.Collectors;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Lazy;
import org.springframework.stereotype.Component;
import tech.trenero.backend.attendance.external.AttendanceSpi;
import tech.trenero.backend.attendance.internal.entity.Attendance;
import tech.trenero.backend.attendance.internal.mapper.AttendanceMapper;
import tech.trenero.backend.attendance.internal.service.AttendanceService;
import tech.trenero.backend.codegen.types.CreateAttendanceInput;
import tech.trenero.backend.common.security.JwtUser;
import tech.trenero.backend.student.external.StudentSpi;

@Component
@RequiredArgsConstructor
public class AttendanceSpiImpl implements AttendanceSpi {
  private static final String JWT_USER_MUST_NOT_BE_NULL = "jwtUser must not be null";
  private static final String LESSON_ID_MUST_NOT_BE_NULL = "lessonId must not be null";
  private final AttendanceService attendanceService;
  private final AttendanceMapper attendanceMapper;
  @Lazy private final StudentSpi studentSpi;

  @Override
  public List<tech.trenero.backend.codegen.types.Attendance> getAttendancesByStudentId(
      UUID studentId, JwtUser jwtUser) {
    Objects.requireNonNull(studentId, "studentId must not be null");
    Objects.requireNonNull(jwtUser, JWT_USER_MUST_NOT_BE_NULL);

    return attendanceService.getAttendancesByStudentId(studentId, jwtUser);
  }

  @Override
  public List<tech.trenero.backend.codegen.types.Attendance> getAttendancesByLessonId(
      UUID lessonId, JwtUser jwtUser) {
    Objects.requireNonNull(lessonId, LESSON_ID_MUST_NOT_BE_NULL);
    Objects.requireNonNull(jwtUser, JWT_USER_MUST_NOT_BE_NULL);

    return attendanceService.getAttendancesByLessonId(lessonId, jwtUser);
  }

  @Override
  public void createAttendances(
      UUID lessonId,
      UUID groupId,
      List<CreateAttendanceInput> attendanceInputList,
      JwtUser jwtUser) {
    Objects.requireNonNull(lessonId, LESSON_ID_MUST_NOT_BE_NULL);
    Objects.requireNonNull(groupId, "groupId must not be null");
    Objects.requireNonNull(attendanceInputList, "attendanceInputList must not be null");
    Objects.requireNonNull(jwtUser, JWT_USER_MUST_NOT_BE_NULL);

    if (attendanceInputList.isEmpty()) {
      return;
    }

    List<UUID> studentIds =
        attendanceInputList.stream().map(CreateAttendanceInput::getStudentId).toList();

    studentSpi.getStudentsByIds(studentIds, jwtUser);

    List<Attendance> attendances =
        attendanceInputList.stream()
            .map(input -> attendanceMapper.toAttendance(input, jwtUser.userId()))
            .toList();

    attendanceService.saveAttendanceList(attendances);
  }

  @Override
  public void editAttendancesByLessonId(
      UUID lessonId, List<CreateAttendanceInput> input, JwtUser jwtUser) {
    Objects.requireNonNull(lessonId, LESSON_ID_MUST_NOT_BE_NULL);
    Objects.requireNonNull(input, "input must not be null");
    Objects.requireNonNull(jwtUser, JWT_USER_MUST_NOT_BE_NULL);

    if (input.isEmpty()) {
      return;
    }

    List<UUID> studentIds = input.stream().map(CreateAttendanceInput::getStudentId).toList();
    studentSpi.getStudentsByIds(studentIds, jwtUser);

    Map<UUID, tech.trenero.backend.codegen.types.Attendance> existingMap =
        attendanceService.getAttendancesByLessonId(lessonId, jwtUser).stream()
            .collect(Collectors.toMap(a -> a.getStudent().getId(), Function.identity()));

    List<Attendance> attendancesToSave =
        input.stream()
            .map(
                in -> {
                  tech.trenero.backend.codegen.types.Attendance existing =
                      existingMap.get(in.getStudentId());

                  Attendance attendance = attendanceMapper.toAttendance(in, jwtUser.userId());

                  if (existing != null) {
                    attendance.setId(existing.getId());
                  }

                  return attendance;
                })
            .toList();

    if (!attendancesToSave.isEmpty()) {
      attendanceService.saveAttendanceList(attendancesToSave);
    }
  }

  @Override
  public void removeAttendancesByLessonId(UUID lessonId, JwtUser jwtUser) {
    Objects.requireNonNull(lessonId, LESSON_ID_MUST_NOT_BE_NULL);
    Objects.requireNonNull(jwtUser, JWT_USER_MUST_NOT_BE_NULL);

    attendanceService.getAttendancesByLessonId(lessonId, jwtUser).stream()
        .map(tech.trenero.backend.codegen.types.Attendance::getId)
        .forEach(id -> attendanceService.softDeleteAttendance(id, jwtUser));
  }
}
