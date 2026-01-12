package tech.trenero.backend.attendance.internal.service;

import jakarta.validation.Valid;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import tech.trenero.backend.attendance.internal.entity.Attendance;
import tech.trenero.backend.attendance.internal.mapper.AttendanceMapper;
import tech.trenero.backend.attendance.internal.repository.AttendanceRepository;
import tech.trenero.backend.common.dto.AttendanceDto;
import tech.trenero.backend.common.input.CreateAttendanceInput;
import tech.trenero.backend.common.security.JwtUser;
import tech.trenero.backend.lesson.external.LessonValidator;
import tech.trenero.backend.student.external.StudentValidator;

@Service
@Slf4j
@RequiredArgsConstructor
public class AttendanceService {
  private final AttendanceRepository attendanceRepository;
  private final AttendanceMapper attendanceMapper;
  private final StudentValidator studentValidator;
  private final LessonValidator lessonValidator;

  @Transactional(readOnly = true)
  public List<AttendanceDto> getAllAttendances(JwtUser jwtUser) {
    log.info("Getting all attendances for ownerId={}", jwtUser.userId());
    return attendanceRepository.findAllByOwnerId(jwtUser.userId()).stream()
        .map(attendanceMapper::toDto)
        .toList();
  }

  @Transactional(readOnly = true)
  public Optional<AttendanceDto> getAttendanceById(UUID attendanceId, JwtUser jwtUser) {
    log.info("Getting attendance by id={} for ownerId={}", attendanceId, jwtUser.userId());
    return attendanceRepository
        .findByIdAndOwnerId(attendanceId, jwtUser.userId())
        .map(attendanceMapper::toDto);
  }

  @Transactional(readOnly = true)
  public Optional<AttendanceDto> getAttendanceByLessonIdAndStudentId(
      UUID lessonId, UUID studentId, JwtUser jwtUser) {
    return attendanceRepository
        .findByLessonIdAndStudentIdAndOwnerId(lessonId, studentId, jwtUser.userId())
        .map(attendanceMapper::toDto);
  }

  @Transactional(readOnly = true)
  public List<AttendanceDto> getAttendancesByLessonId(UUID lessonId, JwtUser jwtUser) {
    log.info("Getting attendances by lessonId={} for ownerId={}", lessonId, jwtUser.userId());
    return attendanceRepository.findAllByLessonIdAndOwnerId(lessonId, jwtUser.userId()).stream()
        .map(attendanceMapper::toDto)
        .toList();
  }

  @Transactional
  public AttendanceDto createAttendance(CreateAttendanceInput input, JwtUser jwtUser) {
    log.info(
        "Creating attendance for lessonId='{}', studentId='{}', present={}, ownerId={}",
        input.lessonId(),
        input.studentId(),
        input.present(),
        jwtUser.userId());

    studentValidator.validateStudentId(input.studentId(), jwtUser);
    lessonValidator.validateLessonIsPresentAndActive(input.lessonId(), jwtUser);

    Attendance attendance = attendanceMapper.toAttendance(input, jwtUser.userId());

    Attendance savedAttendance = saveAttendance(attendance);

    return attendanceMapper.toDto(savedAttendance);
  }

  @Transactional
  public Optional<AttendanceDto> editAttendance(
      UUID id, @Valid CreateAttendanceInput input, JwtUser jwtUser) {
    return attendanceRepository
        .findByIdAndOwnerId(id, jwtUser.userId())
        .map(attendance -> attendanceMapper.editAttendance(attendance, input))
        .map(this::saveAttendance)
        .map(attendanceMapper::toDto);
  }

  @Transactional
  public Optional<AttendanceDto> softDeleteAttendance(UUID attendanceId, JwtUser jwtUser) {
    log.info("Soft deleting attendance: {}", attendanceId);
    return attendanceRepository
        .findByIdAndOwnerId(attendanceId, jwtUser.userId())
        .map(
            attendance -> {
              attendance.setDeletedAt(OffsetDateTime.now());
              return saveAttendance(attendance);
            })
        .map(attendanceMapper::toDto);
  }

  @Transactional(readOnly = true)
  public List<AttendanceDto> getAttendancesByStudentId(UUID studentId, JwtUser jwtUser) {
    log.info("Getting attendances by studentId={} for ownerId={}", studentId, jwtUser.userId());
    return attendanceRepository.findAllByStudentIdAndOwnerId(studentId, jwtUser.userId()).stream()
        .map(attendanceMapper::toDto)
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
