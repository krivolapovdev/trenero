package tech.trenero.backend.student.internal.service;

import java.util.List;
import java.util.Optional;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import tech.trenero.backend.common.dto.StudentDto;
import tech.trenero.backend.common.security.JwtUser;
import tech.trenero.backend.group.external.GroupValidator;
import tech.trenero.backend.student.internal.entity.Student;
import tech.trenero.backend.student.internal.input.CreateStudentInput;
import tech.trenero.backend.student.internal.mapper.StudentMapper;
import tech.trenero.backend.student.internal.repository.StudentRepository;

@Service
@RequiredArgsConstructor
@Slf4j
public class StudentService {
  private final StudentRepository studentRepository;
  private final StudentMapper studentMapper;
  private final GroupValidator groupValidator;

  @Transactional(readOnly = true)
  public List<StudentDto> getAllStudents(JwtUser jwtUser) {
    log.info("Getting all students for ownerId={}", jwtUser.userId());
    return studentRepository.findAllByOwnerIdAndDeletedFalse(jwtUser.userId()).stream()
        .map(studentMapper::toStudentDto)
        .toList();
  }

  @Transactional(readOnly = true)
  public Optional<StudentDto> getStudentById(UUID studentId, JwtUser jwtUser) {
    log.info("Getting student by id={} for ownerId={}", studentId, jwtUser.userId());
    return studentRepository
        .findByIdAndOwnerId(studentId, jwtUser.userId())
        .map(studentMapper::toStudentDto);
  }

  @Transactional
  public StudentDto createStudent(CreateStudentInput input, JwtUser jwtUser) {
    log.info("Creating student: {}", input);

    groupValidator.validateGroupIsPresentAndActive(input.groupId(), jwtUser);

    Student student = studentMapper.toStudent(input, jwtUser.userId());

    Student savedStudent = saveStudent(student);

    return studentMapper.toStudentDto(savedStudent);
  }

  @Transactional
  public Optional<StudentDto> softDeleteStudent(UUID id, JwtUser jwtUser) {
    log.info("Deleting student: {}", id);
    return studentRepository
        .findByIdAndOwnerId(id, jwtUser.userId())
        .map(
            student -> {
              student.setDeleted(true);
              return saveStudent(student);
            })
        .map(studentMapper::toStudentDto);
  }

  @Transactional(readOnly = true)
  public List<StudentDto> getStudentsByGroupId(UUID groupId, JwtUser jwtUser) {
    log.info("Getting students by groupId={} for ownerId={}", groupId, jwtUser.userId());
    return studentRepository.findAllByGroupIdAndOwnerId(groupId, jwtUser.userId()).stream()
        .map(studentMapper::toStudentDto)
        .toList();
  }

  @Transactional
  public void setGroupIdToStudents(UUID groupId, List<UUID> studentIds, JwtUser jwtUser) {
    log.info(
        "Setting groupId={} to students={} for ownerId={}", groupId, studentIds, jwtUser.userId());

    groupValidator.validateGroupIsPresentAndActive(groupId, jwtUser);

    int updatedCount =
        studentRepository.setGroupIdForStudents(groupId, studentIds, jwtUser.userId());

    log.info("Updated {} students with new groupId={}", updatedCount, groupId);
  }

  private Student saveStudent(Student student) {
    log.info("Saving student: {}", student);
    return studentRepository.save(student);
  }
}
