package tech.trenero.backend.student.internal.service;

import jakarta.persistence.EntityNotFoundException;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Lazy;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import tech.trenero.backend.common.response.StudentResponse;
import tech.trenero.backend.common.security.JwtUser;
import tech.trenero.backend.group.external.GroupSpi;
import tech.trenero.backend.student.external.StudentSpi;
import tech.trenero.backend.student.internal.entity.Student;
import tech.trenero.backend.student.internal.mapper.StudentMapper;
import tech.trenero.backend.student.internal.repository.StudentRepository;
import tech.trenero.backend.student.internal.request.CreateStudentRequest;
import tech.trenero.backend.student.internal.request.UpdateStudentRequest;

@Service
@RequiredArgsConstructor
@Slf4j
public class StudentService implements StudentSpi {
  private final StudentRepository studentRepository;
  private final StudentMapper studentMapper;
  @Lazy private final GroupSpi groupSpi;

  @Transactional(readOnly = true)
  public List<StudentResponse> getAllStudents(JwtUser jwtUser) {
    log.info("Getting all students for ownerId={}", jwtUser.userId());
    return studentRepository.findAllByOwnerIdAndDeletedFalse(jwtUser.userId()).stream()
        .map(studentMapper::toResponse)
        .toList();
  }

  @Transactional(readOnly = true)
  public StudentResponse getStudentById(UUID studentId, JwtUser jwtUser) {
    log.info("Getting student by id={} for ownerId={}", studentId, jwtUser.userId());
    return studentRepository
        .findByIdAndOwnerId(studentId, jwtUser.userId())
        .map(studentMapper::toResponse)
        .orElseThrow(
            () -> new EntityNotFoundException("Student with id=" + studentId + " not found"));
  }

  @Transactional(readOnly = true)
  public List<StudentResponse> getStudentsByGroupId(UUID groupId, JwtUser jwtUser) {
    log.info("Getting students by groupId={} for ownerId={}", groupId, jwtUser.userId());
    return studentRepository.findAllByGroupIdAndOwnerId(groupId, jwtUser.userId()).stream()
        .map(studentMapper::toResponse)
        .toList();
  }

  @Transactional
  public StudentResponse createStudent(CreateStudentRequest request, JwtUser jwtUser) {
    log.info("Creating student: {}", request);

    if (request.groupId() != null) {
      groupSpi.getGroupById(request.groupId(), jwtUser);
    }

    Student student = studentMapper.toStudent(request, jwtUser.userId());

    Student savedStudent = saveStudent(student);

    return studentMapper.toResponse(savedStudent);
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

  @Override
  public void editStudentsGroup(UUID groupId, List<UUID> studentIds, JwtUser jwtUser) {}

  @Override
  public void removeGroupFromStudents(UUID groupId, JwtUser jwtUser) {}

  @Transactional
  public void removeGroupFromStudents(List<UUID> studentIds, JwtUser jwtUser) {
    log.info("Remove from group from students={} for ownerId={}", studentIds, jwtUser.userId());

    int updatedCount = studentRepository.setGroupIdForStudents(null, studentIds, jwtUser.userId());

    log.info("Updated {} students with empty groupId", updatedCount);
  }

  @Transactional(readOnly = true)
  public List<StudentResponse> getStudentListByIds(List<UUID> studentIds, JwtUser jwtUser) {
    log.info("Getting students by ids={} for ownerId={}", studentIds, jwtUser.userId());

    return studentRepository.findAllByIdsAndOwnerId(studentIds, jwtUser.userId()).stream()
        .map(studentMapper::toResponse)
        .toList();
  }

  @Transactional
  public StudentResponse updateStudent(
      UUID studentId, UpdateStudentRequest request, JwtUser jwtUser) {
    log.info(
        "Updating student ID: {} for user: {}. Input: {}", studentId, jwtUser.userId(), request);

    return studentRepository
        .findByIdAndOwnerId(studentId, jwtUser.userId())
        .map(student -> studentMapper.updateStudent(student, request))
        .map(this::saveStudent)
        .map(studentMapper::toResponse)
        .orElseThrow(() -> new EntityNotFoundException("Student not found with id=" + studentId));
  }

  @Transactional
  public void softDeleteStudent(UUID studentId, JwtUser jwtUser) {
    log.info("Deleting student: {}", studentId);

    studentRepository
        .findByIdAndOwnerId(studentId, jwtUser.userId())
        .map(
            student -> {
              student.setDeletedAt(OffsetDateTime.now());
              return saveStudent(student);
            })
        .orElseThrow(() -> new EntityNotFoundException("Student not found with id=" + studentId));
  }

  private Student saveStudent(Student student) {
    log.info("Saving student: {}", student);
    return studentRepository.saveAndFlush(student);
  }
}
