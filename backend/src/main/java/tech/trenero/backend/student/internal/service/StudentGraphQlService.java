package tech.trenero.backend.student.internal.service;

import jakarta.persistence.EntityNotFoundException;
import java.util.List;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Lazy;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import tech.trenero.backend.common.security.JwtUser;
import tech.trenero.backend.group.external.GroupSpi;
import tech.trenero.backend.student.internal.entity.Student;
import tech.trenero.backend.student.internal.repository.StudentRepository;
import tech.trenero.backend.student.internal.request.CreateStudentInput;

@Service
@RequiredArgsConstructor
@Slf4j
public class StudentGraphQlService {
  private final StudentRepository studentRepository;
  @Lazy private final GroupSpi groupSpi;

  public List<Student> getAllStudents(JwtUser jwtUser) {
    log.info("Getting all students for ownerId={}", jwtUser.userId());
    return studentRepository.findAllByOwnerIdAndDeletedFalse(jwtUser.userId()).stream().toList();
  }

  public Student getStudentById(UUID studentId, JwtUser jwtUser) {
    log.info("Getting student by id={} for ownerId={}", studentId, jwtUser.userId());

    return studentRepository
        .findByIdAndOwnerId(studentId, jwtUser.userId())
        .orElseThrow(
            () ->
                new EntityNotFoundException(
                    "Student not found with id: " + studentId + " for current user"));
  }

  @Transactional
  public Student createStudent(CreateStudentInput input, JwtUser jwtUser) {
    log.info("Creating student: {}", input);

    Student student =
        Student.builder()
            .fullName(input.fullName())
            .ownerId(jwtUser.userId())
            .birthDate(input.birthDate())
            .phone(input.phone())
            .note(input.note())
            .groupId(input.groupId())
            .build();

    Student savedStudent = saveStudent(student);

    return savedStudent;
  }

  @Transactional
  public Student saveStudent(Student student) {
    log.info("Saving student: {}", student);
    return studentRepository.save(student);
  }

  @Transactional
  public Student softDeleteStudent(UUID id, JwtUser jwtUser) {
    log.info("Deleting student: {}", id);
    Student student =
        studentRepository
            .findByIdAndOwnerId(id, jwtUser.userId())
            .orElseThrow(() -> new EntityNotFoundException("Student not found"));
    student.setDeleted(true);
    return studentRepository.save(student);
  }
}
