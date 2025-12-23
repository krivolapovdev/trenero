package tech.trenero.backend.student.internal.service;

import jakarta.persistence.EntityNotFoundException;
import java.util.List;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import tech.trenero.backend.common.response.StudentResponse;
import tech.trenero.backend.common.security.JwtUser;
import tech.trenero.backend.student.internal.mapper.StudentMapper;
import tech.trenero.backend.student.internal.repository.StudentRepository;

@Service
@RequiredArgsConstructor
@Slf4j
public class StudentService {
  private final StudentRepository studentRepository;
  private final StudentMapper studentMapper;

  public StudentResponse getStudentById(UUID studentId, JwtUser jwtUser) {
    log.info("Getting student by id={} for ownerId={}", studentId, jwtUser.userId());

    return studentRepository
        .findByIdAndOwnerId(studentId, jwtUser.userId())
        .map(studentMapper::toStudentResponse)
        .orElseThrow(
            () ->
                new EntityNotFoundException(
                    "Student not found with id: " + studentId + " for current user"));
  }

  public List<StudentResponse> getStudentsByIds(List<UUID> studentIds, JwtUser jwtUser) {
    log.info(
        "Getting students by ids={} for ownerId={}",
        studentIds != null ? studentIds.toString() : null,
        jwtUser.userId());
    return studentRepository.findAllByIdInAndOwnerId(studentIds, jwtUser.userId()).stream()
        .map(studentMapper::toStudentResponse)
        .toList();
  }
}
