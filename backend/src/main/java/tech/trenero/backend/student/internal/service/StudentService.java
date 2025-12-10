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
import tech.trenero.backend.student.internal.request.StudentRequest;
import tech.trenero.backend.student.internal.response.StudentWithGroupsResponse;

@Service
@RequiredArgsConstructor
@Slf4j
public class StudentService {
  private final StudentRepository studentRepository;
  private final StudentMapper studentMapper;
  private final StudentGroupService studentGroupService;
  private final StudentGroupClient studentGroupClient;

  public List<StudentResponse> getAllStudents(JwtUser jwtUser) {
    log.info("Getting all students for ownerId={}", jwtUser.userId());
    return studentRepository.findAllByOwnerIdAndDeletedFalse(jwtUser.userId()).stream()
        .map(studentMapper::toStudentResponse)
        .toList();
  }

  public StudentWithGroupsResponse getStudentById(UUID studentId, JwtUser jwtUser) {
    log.info("Getting student by id={} for ownerId={}", studentId, jwtUser.userId());

    Student student =
        studentRepository
            .findByIdAndOwnerId(studentId, jwtUser.userId())
            .orElseThrow(
                () ->
                    new EntityNotFoundException(
                        "Student not found with id: " + studentId + " for current user"));

    List<UUID> groupIds = studentGroupService.getGroupIdsByStudentIdForUser(studentId, jwtUser);

    List<GroupResponse> studentGroups = studentGroupClient.getGroupsByIds(groupIds, jwtUser);

    StudentResponse studentResponse = studentMapper.toStudentResponse(student);

    return new StudentWithGroupsResponse(studentResponse, studentGroups);
  }

  public List<StudentResponse> getStudentsByGroupId(UUID groupId, JwtUser jwtUser) {
    log.info("Getting students by groupId={} for ownerId={}", groupId, jwtUser.userId());
    return studentRepository.findAllByGroupIdAndOwnerId(groupId, jwtUser.userId()).stream()
        .map(studentMapper::toStudentResponse)
        .toList();
  }

  @Transactional
  public UUID createStudent(StudentRequest request, JwtUser jwtUser) {
    log.info("Creating student: {}", request);

    Student student = studentMapper.toStudent(request);
    student.setOwnerId(jwtUser.userId());

    Student savedStudent = saveStudent(student);
    UUID savedStudentId = savedStudent.getId();

    studentGroupService.assignGroupsToStudent(savedStudentId, request.studentGroups());

    return savedStudentId;
  }

  public Student saveStudent(Student student) {
    log.info("Saving student: {}", student);
    return studentRepository.save(student);
  }

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
