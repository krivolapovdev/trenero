package tech.trenero.backend.attendance.internal.spi;

import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;
import java.util.stream.Collectors;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Lazy;
import org.springframework.stereotype.Component;
import tech.trenero.backend.attendance.external.AttendanceSpi;
import tech.trenero.backend.attendance.internal.entity.Attendance;
import tech.trenero.backend.attendance.internal.mapper.AttendanceMapper;
import tech.trenero.backend.attendance.internal.service.AttendanceService;
import tech.trenero.backend.common.dto.AttendanceDto;
import tech.trenero.backend.common.input.CreateAttendanceInput;
import tech.trenero.backend.common.security.JwtUser;
import tech.trenero.backend.lesson.external.LessonSpi;
import tech.trenero.backend.student.external.StudentValidator;

@Component
@RequiredArgsConstructor
public class AttendanceSpiImpl implements AttendanceSpi {
  private final AttendanceService attendanceService;
  private final AttendanceMapper attendanceMapper;
  @Lazy private final LessonSpi lessonSpi;
  @Lazy private final StudentValidator studentValidator;

  @Override
  public Optional<AttendanceDto> getLastStudentAttendance(
      UUID studentId, UUID groupId, JwtUser jwtUser) {
    if (studentId == null || groupId == null || jwtUser == null) {
      return Optional.empty();
    }

    return lessonSpi
        .getLastLessonByGroupId(groupId, jwtUser)
        .flatMap(
            lesson ->
                attendanceService.getAttendanceByLessonIdAndStudentId(
                    lesson.id(), studentId, jwtUser));
  }

  @Override
  public List<AttendanceDto> getAttendancesByStudentId(UUID studentId, JwtUser jwtUser) {
    if (studentId == null || jwtUser == null) {
      return List.of();
    }

    return attendanceService.getAttendancesByStudentId(studentId, jwtUser);
  }

  @Override
  public List<AttendanceDto> getAttendancesByLessonId(UUID lessonId, JwtUser jwtUser) {
    if (lessonId == null || jwtUser == null) {
      return List.of();
    }

    return attendanceService.getAttendancesByLessonId(lessonId, jwtUser);
  }

  @Override
  public void createAttendances(
      UUID lessonId,
      UUID groupId,
      List<CreateAttendanceInput> attendanceInputList,
      JwtUser jwtUser) {
    if (lessonId == null
        || attendanceInputList == null
        || attendanceInputList.isEmpty()
        || jwtUser == null) {
      return;
    }

    List<UUID> studentIds =
        attendanceInputList.stream().map(CreateAttendanceInput::studentId).toList();

    studentValidator.validateStudentIdsList(studentIds, jwtUser);

    List<Attendance> attendances =
        attendanceInputList.stream()
            .map(input -> attendanceMapper.toAttendance(input, jwtUser.userId()))
            .toList();

    attendanceService.saveAttendanceList(attendances);
  }

  @Override
  public void editAttendancesByLessonId(
      UUID lessonId, List<CreateAttendanceInput> input, JwtUser jwtUser) {
    if (lessonId == null || input == null || jwtUser == null) {
      return;
    }

    List<AttendanceDto> existingAttendances =
        attendanceService.getAttendancesByLessonId(lessonId, jwtUser);

    Map<UUID, AttendanceDto> existingMap =
        existingAttendances.stream().collect(Collectors.toMap(AttendanceDto::studentId, a -> a));

    List<Attendance> toUpdate =
        input.stream()
            .filter(in -> existingMap.containsKey(in.studentId()))
            .map(in -> attendanceMapper.toAttendance(in, jwtUser.userId()))
            .toList();

    List<Attendance> toAdd =
        input.stream()
            .filter(in -> !existingMap.containsKey(in.studentId()))
            .map(in -> attendanceMapper.toAttendance(in, jwtUser.userId()))
            .toList();

    if (!toUpdate.isEmpty()) {
      attendanceService.saveAttendanceList(toUpdate);
    }

    if (!toAdd.isEmpty()) {
      attendanceService.saveAttendanceList(toAdd);
    }
  }
}
