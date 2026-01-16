package tech.trenero.backend.attendance.internal.service;

import jakarta.validation.Valid;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Lazy;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import tech.trenero.backend.attendance.internal.entity.Attendance;
import tech.trenero.backend.attendance.internal.mapper.AttendanceMapper;
import tech.trenero.backend.attendance.internal.repository.AttendanceRepository;
import tech.trenero.backend.codegen.types.CreateAttendanceInput;
import tech.trenero.backend.common.security.JwtUser;
import tech.trenero.backend.lesson.external.LessonSpi;

@Service
@Slf4j
@RequiredArgsConstructor
public class AttendanceService {
  private final AttendanceRepository attendanceRepository;
  private final AttendanceMapper attendanceMapper;
  @Lazy private final LessonSpi lessonSpi;

  @Transactional(readOnly = true)
  public List<tech.trenero.backend.codegen.types.Attendance> getAllAttendances(JwtUser jwtUser) {
    log.info("Getting all attendances for ownerId={}", jwtUser.userId());
    return attendanceRepository.findAllByOwnerId(jwtUser.userId()).stream()
        .map(attendanceMapper::toGraphql)
        .toList();
  }

  @Transactional(readOnly = true)
  public Optional<tech.trenero.backend.codegen.types.Attendance> findAttendanceById(
      UUID attendanceId, JwtUser jwtUser) {
    log.info("Getting attendance by id={} for ownerId={}", attendanceId, jwtUser.userId());
    return attendanceRepository
        .findByIdAndOwnerId(attendanceId, jwtUser.userId())
        .map(attendanceMapper::toGraphql);
  }

  @Transactional(readOnly = true)
  public List<tech.trenero.backend.codegen.types.Attendance> getAttendancesByLessonId(
      UUID lessonId, JwtUser jwtUser) {
    log.info("Getting attendances by lessonId={} for ownerId={}", lessonId, jwtUser.userId());
    return attendanceRepository.findAllByLessonIdAndOwnerId(lessonId, jwtUser.userId()).stream()
        .map(attendanceMapper::toGraphql)
        .toList();
  }

  @Transactional
  public tech.trenero.backend.codegen.types.Attendance createAttendance(
      CreateAttendanceInput input, JwtUser jwtUser) {
    log.info(
        "Creating attendance for lessonId='{}', studentId='{}', present={}, ownerId={}",
        input.getLessonId(),
        input.getStudentId(),
        input.getPresent(),
        jwtUser.userId());

    lessonSpi.getLessonById(input.getLessonId(), jwtUser);

    Attendance attendance = attendanceMapper.toAttendance(input, jwtUser.userId());

    Attendance savedAttendance = saveAttendance(attendance);

    return attendanceMapper.toGraphql(savedAttendance);
  }

  @Transactional
  public Optional<tech.trenero.backend.codegen.types.Attendance> editAttendance(
      UUID id, @Valid CreateAttendanceInput input, JwtUser jwtUser) {
    return attendanceRepository
        .findByIdAndOwnerId(id, jwtUser.userId())
        .map(attendance -> attendanceMapper.editAttendance(attendance, input))
        .map(this::saveAttendance)
        .map(attendanceMapper::toGraphql);
  }

  @Transactional
  public Optional<tech.trenero.backend.codegen.types.Attendance> softDeleteAttendance(
      UUID attendanceId, JwtUser jwtUser) {
    log.info("Soft deleting attendance: {}", attendanceId);
    return attendanceRepository
        .findByIdAndOwnerId(attendanceId, jwtUser.userId())
        .map(
            attendance -> {
              attendance.setDeletedAt(OffsetDateTime.now());
              return saveAttendance(attendance);
            })
        .map(attendanceMapper::toGraphql);
  }

  @Transactional(readOnly = true)
  public List<tech.trenero.backend.codegen.types.Attendance> getAttendancesByStudentId(
      UUID studentId, JwtUser jwtUser) {
    log.info("Getting attendances by studentId={} for ownerId={}", studentId, jwtUser.userId());
    return attendanceRepository.findAllByStudentIdAndOwnerId(studentId, jwtUser.userId()).stream()
        .map(attendanceMapper::toGraphql)
        .toList();
  }

  private Attendance saveAttendance(Attendance attendance) {
    log.info("Saving attendance: {}", attendance);
    return attendanceRepository.saveAndFlush(attendance);
  }

  @Transactional
  public void saveAttendanceList(List<Attendance> attendanceList) {
    log.info("Saving attendance list: {}", attendanceList);
    attendanceRepository.saveAllAndFlush(attendanceList);
  }
}
