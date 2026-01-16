package tech.trenero.backend.student.internal.service;

import graphql.schema.DataFetchingEnvironment;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Lazy;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import tech.trenero.backend.codegen.types.CreateStudentInput;
import tech.trenero.backend.codegen.types.UpdateStudentInput;
import tech.trenero.backend.common.security.JwtUser;
import tech.trenero.backend.group.external.GroupSpi;
import tech.trenero.backend.student.internal.entity.Student;
import tech.trenero.backend.student.internal.mapper.StudentMapper;
import tech.trenero.backend.student.internal.repository.StudentRepository;

@Service
@RequiredArgsConstructor
@Slf4j
public class StudentService {
  private final StudentRepository studentRepository;
  private final StudentMapper studentMapper;
  @Lazy private final GroupSpi groupSpi;

  @Transactional(readOnly = true)
  public List<tech.trenero.backend.codegen.types.Student> getAllStudents(JwtUser jwtUser) {
    log.info("Getting all students for ownerId={}", jwtUser.userId());
    return studentRepository.findAllByOwnerIdAndDeletedFalse(jwtUser.userId()).stream()
        .map(studentMapper::toGraphql)
        .toList();
  }

  @Transactional(readOnly = true)
  public Optional<tech.trenero.backend.codegen.types.Student> findStudentById(
      UUID studentId, JwtUser jwtUser) {
    log.info("Getting student by id={} for ownerId={}", studentId, jwtUser.userId());
    return studentRepository
        .findByIdAndOwnerId(studentId, jwtUser.userId())
        .map(studentMapper::toGraphql);
  }

  @Transactional
  public tech.trenero.backend.codegen.types.Student createStudent(
      CreateStudentInput input, JwtUser jwtUser) {
    log.info("Creating student: {}", input);

    groupSpi.getGroupById(input.getGroupId(), jwtUser);

    Student student = studentMapper.toStudent(input, jwtUser.userId());

    Student savedStudent = saveStudent(student);

    return studentMapper.toGraphql(savedStudent);
  }

  @Transactional
  public Optional<tech.trenero.backend.codegen.types.Student> softDeleteStudent(
      UUID id, JwtUser jwtUser) {
    log.info("Deleting student: {}", id);
    return studentRepository
        .findByIdAndOwnerId(id, jwtUser.userId())
        .map(
            student -> {
              student.setDeletedAt(OffsetDateTime.now());
              return saveStudent(student);
            })
        .map(studentMapper::toGraphql);
  }

  @Transactional(readOnly = true)
  public List<tech.trenero.backend.codegen.types.Student> getStudentsByGroupId(
      UUID groupId, JwtUser jwtUser) {
    log.info("Getting students by groupId={} for ownerId={}", groupId, jwtUser.userId());
    return studentRepository.findAllByGroupIdAndOwnerId(groupId, jwtUser.userId()).stream()
        .map(studentMapper::toGraphql)
        .toList();
  }

  @Transactional
  public void assignGroupToStudents(UUID groupId, List<UUID> studentIds, JwtUser jwtUser) {
    log.info(
        "Assign groupId={} to students={} for ownerId={}", groupId, studentIds, jwtUser.userId());

    groupSpi.getGroupById(groupId, jwtUser);

    int updatedCount =
        studentRepository.setGroupIdForStudents(groupId, studentIds, jwtUser.userId());

    log.info("Updated {} students with new groupId={}", updatedCount, groupId);
  }

  @Transactional(readOnly = true)
  public List<tech.trenero.backend.codegen.types.Student> getStudentListByIds(
      List<UUID> studentIds, JwtUser jwtUser) {
    log.info("Getting students by ids={} for ownerId={}", studentIds, jwtUser.userId());
    return studentRepository.findAllByIdsAndOwnerId(studentIds, jwtUser.userId()).stream()
        .map(studentMapper::toGraphql)
        .toList();
  }

  @Transactional
  public Optional<tech.trenero.backend.codegen.types.Student> updateStudent(
      UUID studentId,
      UpdateStudentInput input,
      DataFetchingEnvironment environment,
      JwtUser jwtUser) {
    log.info("Updating student ID: {} for user: {}. Input: {}", studentId, jwtUser.userId(), input);
    return studentRepository
        .findByIdAndOwnerId(studentId, jwtUser.userId())
        .map(student -> studentMapper.updateStudent(student, input, environment))
        .map(this::saveStudent)
        .map(studentMapper::toGraphql);
  }

  private Student saveStudent(Student student) {
    log.info("Saving student: {}", student);
    return studentRepository.saveAndFlush(student);
  }
}
