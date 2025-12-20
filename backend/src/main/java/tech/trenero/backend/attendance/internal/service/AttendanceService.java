package tech.trenero.backend.attendance.internal.service;

import jakarta.transaction.Transactional;
import java.util.List;
import java.util.Objects;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Lazy;
import org.springframework.stereotype.Service;
import tech.trenero.backend.attendance.internal.entity.StudentAttendance;
import tech.trenero.backend.attendance.internal.mapper.StudentAttendanceMapper;
import tech.trenero.backend.attendance.internal.repository.StudentAttendanceRepository;
import tech.trenero.backend.attendance.internal.request.LessonRequest;
import tech.trenero.backend.common.security.JwtUser;
import tech.trenero.backend.group.external.GroupSpi;

@Service
@RequiredArgsConstructor
@Slf4j
public class AttendanceService {
  private final StudentAttendanceRepository attendanceRepository;
  private final LessonService lessonService;
  private final StudentAttendanceMapper studentAttendanceMapper;
  @Lazy private final GroupSpi groupSpi;

  @Transactional
  public UUID createLessonWithAttendance(LessonRequest lessonRequest, JwtUser jwtUser) {
    log.info("Creating lesson with attendance={} and user={}", lessonRequest, jwtUser);

    validateUserGroupAccess(lessonRequest.groupId(), jwtUser);

    var lesson = lessonService.createLesson(lessonRequest);

    List<StudentAttendance> studentAttendanceList =
        lessonRequest.attendance().stream()
            .filter(Objects::nonNull)
            .map(attend -> studentAttendanceMapper.toStudentAttendance(attend, lesson))
            .toList();

    attendanceRepository.saveAll(studentAttendanceList);

    return lesson.getId();
  }

  private void validateUserGroupAccess(UUID groupId, JwtUser jwtUser) {
    log.debug("Checking if user owns group by id={} for user={}", groupId, jwtUser.userId());
    groupSpi.getGroupById(groupId, jwtUser);
  }
}
