package tech.trenero.backend.student.service;

import jakarta.persistence.EntityNotFoundException;
import java.util.List;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import tech.trenero.backend.student.entity.Student;
import tech.trenero.backend.student.mapper.StudentMapper;
import tech.trenero.backend.student.repository.StudentRepository;
import tech.trenero.backend.student.request.StudentRequest;
import tech.trenero.backend.student.response.StudentResponse;

@Service
@RequiredArgsConstructor
@Slf4j
public class StudentService {
  private final StudentRepository studentRepository;
  private final StudentMapper studentMapper;
  private final StudentGroupService studentGroupService;

  public StudentResponse getStudentById(UUID id) {
    log.info("Getting student by id: {}", id);
    return studentRepository
        .findById(id)
        .map(studentMapper::toStudentResponse)
        .orElseThrow(() -> new EntityNotFoundException("Student not found with id: " + id));
  }

  public List<StudentResponse> getStudentsByGroupId(UUID groupId) {
    log.info("Getting students by group id: {}", groupId);
    return studentRepository.getStudentsByGroupId(groupId).stream()
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
