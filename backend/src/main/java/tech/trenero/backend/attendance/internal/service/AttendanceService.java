package tech.trenero.backend.attendance.internal.service;

import java.time.OffsetDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import tech.trenero.backend.attendance.internal.entity.Attendance;
import tech.trenero.backend.attendance.internal.input.CreateAttendanceInput;
import tech.trenero.backend.attendance.internal.repository.AttendanceRepository;
import tech.trenero.backend.common.security.JwtUser;
import tech.trenero.backend.lesson.external.LessonValidator;
import tech.trenero.backend.student.external.StudentValidator;

@Service
@Slf4j
@RequiredArgsConstructor
public class AttendanceService {
  private final AttendanceRepository attendanceRepository;
  private final StudentValidator studentValidator;
  private final LessonValidator lessonValidator;

  public List<Attendance> getAllAttendances(JwtUser jwtUser) {
    log.info("Getting all attendances for ownerId={}", jwtUser.userId());
    return attendanceRepository.findAllByOwnerId(jwtUser.userId()).stream().toList();
  }

  public Optional<Attendance> getAttendanceById(UUID attendanceId, JwtUser jwtUser) {
    log.info("Getting attendance by id={} for ownerId={}", attendanceId, jwtUser.userId());
    return attendanceRepository.findByIdAndOwnerId(attendanceId, jwtUser.userId());
  }

  @Transactional
  public Attendance createAttendance(CreateAttendanceInput input, JwtUser jwtUser) {
    log.info(
        "Creating attendance for lessonId='{}', studentId='{}', present={}, ownerId={}",
        input.lessonId(),
        input.studentId(),
        input.present(),
        jwtUser.userId());

    studentValidator.validateStudentIsPresentAndActive(input.studentId(), jwtUser);
    lessonValidator.validateLessonIsPresentAndActive(input.lessonId(), jwtUser);

    Attendance attendance =
        Attendance.builder()
            .lessonId(input.lessonId())
            .studentId(input.studentId())
            .present(input.present())
            .ownerId(jwtUser.userId())
            .createdAt(OffsetDateTime.now())
            .deleted(false)
            .build();

    return saveAttendance(attendance);
  }

  @Transactional
  public Attendance saveAttendance(Attendance attendance) {
    log.info("Saving attendance: {}", attendance);
    return attendanceRepository.save(attendance);
  }

  @Transactional
  public Optional<Attendance> softDeleteAttendance(UUID attendanceId, JwtUser jwtUser) {
    log.info("Soft deleting attendance: {}", attendanceId);
    return attendanceRepository
        .findByIdAndOwnerId(attendanceId, jwtUser.userId())
        .map(
            attendance -> {
              attendance.setDeleted(true);
              return saveAttendance(attendance);
            });
  }
}
