package tech.trenero.backend.student.service;

import jakarta.persistence.EntityNotFoundException;
import java.util.List;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import tech.trenero.backend.common.response.GroupResponse;
import tech.trenero.backend.common.response.StudentResponse;
import tech.trenero.backend.student.client.GroupClient;
import tech.trenero.backend.student.entity.Student;
import tech.trenero.backend.student.mapper.StudentMapper;
import tech.trenero.backend.student.repository.StudentRepository;
import tech.trenero.backend.student.request.StudentRequest;
import tech.trenero.backend.student.response.StudentWithGroupsResponse;

@Service
@RequiredArgsConstructor
@Slf4j
public class StudentService {
  private final StudentRepository studentRepository;
  private final StudentMapper studentMapper;
  private final StudentGroupService studentGroupService;
  private final GroupClient groupClient;

  public StudentWithGroupsResponse getStudentById(UUID studentId) {
    log.info("Getting student by id: {}", studentId);

    StudentResponse studentResponse =
        studentRepository
            .findById(studentId)
            .map(studentMapper::toStudentResponse)
            .orElseThrow(
                () -> new EntityNotFoundException("Student not found with id: " + studentId));

    List<UUID> groupIds = studentGroupService.getGroupIdsByStudentId(studentId);
    List<GroupResponse> studentGroups = groupClient.getGroupsByIds(groupIds);

    return new StudentWithGroupsResponse(studentResponse, studentGroups);
  }

  public List<StudentResponse> getStudentsByGroupId(UUID groupId) {
    log.info("Getting students by group id: {}", groupId);
    return studentRepository.findStudentsByGroupId(groupId).stream()
        .map(studentMapper::toStudentResponse)
        .toList();
  }

  @Transactional
  public UUID createStudent(StudentRequest request) {
    log.info("Creating student: {}", request);

    Student student = studentMapper.toStudent(request);
    UUID studentId = saveStudent(student);

    studentGroupService.assignGroupsToStudent(studentId, request.studentGroups());

    return studentId;
  }

  public UUID saveStudent(Student student) {
    log.info("Saving student: {}", student);
    Student savedStudent = studentRepository.save(student);
    return savedStudent.getId();
  }
}
