package tech.trenero.backend.student.internal.service;

import jakarta.persistence.EntityNotFoundException;
import java.util.List;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import tech.trenero.backend.common.response.GroupResponse;
import tech.trenero.backend.common.response.StudentResponse;
import tech.trenero.backend.common.security.JwtUser;
import tech.trenero.backend.student.internal.client.StudentGroupClient;
import tech.trenero.backend.student.internal.entity.Student;
import tech.trenero.backend.student.internal.mapper.StudentMapper;
import tech.trenero.backend.student.internal.repository.StudentRepository;
import tech.trenero.backend.student.internal.request.CreateStudentRequest;
import tech.trenero.backend.student.internal.response.StudentWithGroupsResponse;

@Service
@RequiredArgsConstructor
@Slf4j
public class StudentService {
  private final StudentRepository studentRepository;
  private final StudentMapper studentMapper;
  private final StudentGroupClient studentGroupClient;

  public List<StudentResponse> getAllStudents(JwtUser jwtUser) {
    log.info("Getting all students for ownerId={}", jwtUser.userId());
    return studentRepository.findAllByOwnerIdAndDeletedFalse(jwtUser.userId()).stream()
        .map(studentMapper::toStudentResponse)
        .toList();
  }

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
    return studentRepository.findStudentsByIdsAndOwnerId(studentIds, jwtUser.userId()).stream()
        .map(studentMapper::toStudentResponse)
        .toList();
  }

  public StudentWithGroupsResponse getStudentWithGroupsById(UUID studentId, JwtUser jwtUser) {
    log.info("Getting student with groups by id={} for ownerId={}", studentId, jwtUser.userId());

    StudentResponse studentResponse = getStudentById(studentId, jwtUser);

    List<GroupResponse> studentGroups = studentGroupClient.getGroupsByStudentId(studentId, jwtUser);

    return new StudentWithGroupsResponse(studentResponse, studentGroups);
  }

  @Transactional
  public UUID createStudent(CreateStudentRequest request, JwtUser jwtUser) {
    log.info("Creating student: {}", request);

    Student student = studentMapper.toStudent(request);
    student.setOwnerId(jwtUser.userId());

    Student savedStudent = saveStudent(student);

    studentGroupClient.assignGroupsToStudent(
        savedStudent.getId(), request.studentGroups(), jwtUser);

    return savedStudent.getId();
  }

  @Transactional
  public Student saveStudent(Student student) {
    log.info("Saving student: {}", student);
    return studentRepository.save(student);
  }

  @Transactional
  public void softDeleteStudent(UUID studentId, JwtUser jwtUser) {
    log.info("Deleting student: {}", studentId);
    Student student =
        studentRepository
            .findByIdAndOwnerId(studentId, jwtUser.userId())
            .orElseThrow(() -> new EntityNotFoundException("Student not found"));
    student.setDeleted(true);
    studentRepository.save(student);
  }
}
