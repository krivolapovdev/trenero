package tech.trenero.backend.attendance.internal.service;

import jakarta.transaction.Transactional;
import java.util.List;
import java.util.Objects;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import tech.trenero.backend.attendance.internal.client.AttendanceGroupClient;
import tech.trenero.backend.attendance.internal.entity.StudentAttendance;
import tech.trenero.backend.attendance.internal.mapper.StudentAttendanceMapper;
import tech.trenero.backend.attendance.internal.repository.StudentAttendanceRepository;
import tech.trenero.backend.attendance.internal.request.LessonRequest;
import tech.trenero.backend.common.security.JwtUser;

@Service
@RequiredArgsConstructor
@Slf4j
public class AttendanceService {
  private final StudentAttendanceRepository attendanceRepository;
  private final LessonService lessonService;
  private final AttendanceGroupClient attendanceGroupClient;
  private final StudentAttendanceMapper studentAttendanceMapper;

  @Transactional
  public UUID recordAttendance(LessonRequest lessonRequest, JwtUser jwtUser) {
    log.info("Recording attendance={} for user={}", lessonRequest, jwtUser);

    checkUserOwnsGroup(lessonRequest.groupId(), jwtUser);

    var lesson = lessonService.create(lessonRequest);

    List<StudentAttendance> studentAttendanceList =
        lessonRequest.attendance().stream()
            .filter(Objects::nonNull)
            .map(attend -> studentAttendanceMapper.toStudentAttendance(attend, lesson))
            .toList();

    attendanceRepository.saveAll(studentAttendanceList);

    return lesson.getId();
  }

  private void checkUserOwnsGroup(UUID groupId, JwtUser jwtUser) {
    attendanceGroupClient.getForUserById(groupId, jwtUser);
  }
}
