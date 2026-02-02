package tech.trenero.backend.student.internal.service;

import jakarta.persistence.EntityNotFoundException;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Lazy;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import tech.trenero.backend.common.response.GroupResponse;
import tech.trenero.backend.common.response.GroupStudentResponse;
import tech.trenero.backend.common.response.LessonResponse;
import tech.trenero.backend.common.response.StudentPaymentResponse;
import tech.trenero.backend.common.response.StudentResponse;
import tech.trenero.backend.common.response.VisitResponse;
import tech.trenero.backend.common.security.JwtUser;
import tech.trenero.backend.group.external.GroupSpi;
import tech.trenero.backend.group.external.GroupStudentSpi;
import tech.trenero.backend.lesson.external.LessonSpi;
import tech.trenero.backend.payment.external.StudentPaymentSpi;
import tech.trenero.backend.student.external.StudentSpi;
import tech.trenero.backend.student.internal.domain.Student;
import tech.trenero.backend.student.internal.domain.StudentStatus;
import tech.trenero.backend.student.internal.mapper.StudentMapper;
import tech.trenero.backend.student.internal.repository.StudentRepository;
import tech.trenero.backend.student.internal.request.CreateStudentRequest;
import tech.trenero.backend.student.internal.response.StudentDetailsResponse;
import tech.trenero.backend.student.internal.response.StudentOverviewResponse;
import tech.trenero.backend.student.internal.response.VisitWithLessonResponse;
import tech.trenero.backend.visit.external.VisitSpi;

@Service
@RequiredArgsConstructor
@Slf4j
public class StudentService implements StudentSpi {
  @Lazy private final StudentRepository studentRepository;
  @Lazy private final StudentMapper studentMapper;
  @Lazy private final StudentStatusService studentStatusService;
  @Lazy private final StudentService self;
  @Lazy private final GroupSpi groupSpi;
  @Lazy private final GroupStudentSpi groupStudentSpi;
  @Lazy private final StudentPaymentSpi studentPaymentSpi;
  @Lazy private final VisitSpi visitSpi;
  @Lazy private final LessonSpi lessonSpi;

  @Transactional(readOnly = true)
  public List<StudentResponse> getAllStudents(JwtUser jwtUser) {
    log.info("Getting all students for ownerId={}", jwtUser.userId());
    return studentRepository.findAllByOwnerId(jwtUser.userId()).stream()
        .map(studentMapper::toResponse)
        .toList();
  }

  @Transactional(readOnly = true)
  public List<StudentOverviewResponse> getStudentsOverview(JwtUser jwtUser) {
    log.info("Getting students overview for ownerId={}", jwtUser.userId());

    List<StudentResponse> students = self.getAllStudents(jwtUser);

    if (students.isEmpty()) {
      return List.of();
    }

    List<UUID> studentIds = students.stream().map(StudentResponse::id).toList();

    Map<UUID, GroupStudentResponse> studentToGroupLinkMap =
        groupStudentSpi.getGroupStudentsByStudentIds(studentIds, jwtUser);

    List<UUID> groupIds =
        studentToGroupLinkMap.values().stream()
            .map(GroupStudentResponse::groupId)
            .distinct()
            .toList();

    Map<UUID, GroupResponse> groupsMap = groupSpi.getGroupsByIds(groupIds, jwtUser);

    Map<UUID, List<VisitResponse>> visitsMap = visitSpi.getVisitsByStudentIds(studentIds, jwtUser);

    Map<UUID, List<StudentPaymentResponse>> paymentsMap =
        studentPaymentSpi.getStudentPaymentsByStudentIds(studentIds, jwtUser);

    Map<UUID, LessonResponse> groupLessonMap =
        lessonSpi.getLastGroupLessonsByGroupIds(groupIds, jwtUser);

    return students.stream()
        .map(
            student -> {
              GroupStudentResponse link = studentToGroupLinkMap.get(student.id());
              UUID groupId = (link != null) ? link.groupId() : null;

              List<VisitResponse> studentVisits = visitsMap.getOrDefault(student.id(), List.of());
              List<StudentPaymentResponse> studentPayments =
                  paymentsMap.getOrDefault(student.id(), List.of());

              LessonResponse lastLesson = (groupId != null) ? groupLessonMap.get(groupId) : null;

              Set<StudentStatus> statuses =
                  studentStatusService.getStudentStatuses(
                      studentVisits, studentPayments, lastLesson);

              GroupResponse group = (groupId != null) ? groupsMap.get(groupId) : null;

              return new StudentOverviewResponse(student, group, statuses);
            })
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
  public Map<UUID, List<StudentResponse>> getStudentsByIds(List<UUID> studentIds, JwtUser jwtUser) {
    log.info("Getting students by ids={} for ownerId={}", studentIds, jwtUser.userId());

    return studentRepository.findAllByIdsAndOwnerId(studentIds, jwtUser.userId()).stream()
        .map(studentMapper::toResponse)
        .collect(Collectors.groupingBy(StudentResponse::id));
  }

  @Transactional(readOnly = true)
  public StudentDetailsResponse getStudentDetailsById(UUID studentId, JwtUser jwtUser) {
    log.info("Getting student details by id={} for ownerId={}", studentId, jwtUser.userId());

    StudentResponse student = self.getStudentById(studentId, jwtUser);

    Optional<GroupStudentResponse> optionalGroupStudentResponse =
        groupStudentSpi.getGroupsByStudentId(studentId, jwtUser).stream().findFirst();

    UUID groupId = optionalGroupStudentResponse.map(GroupStudentResponse::groupId).orElse(null);

    GroupResponse studentGroup = (groupId != null) ? groupSpi.getGroupById(groupId, jwtUser) : null;

    Optional<LessonResponse> lastGroupLesson =
        (groupId != null) ? lessonSpi.getLastGroupLesson(groupId, jwtUser) : Optional.empty();

    List<VisitResponse> studentVisits = visitSpi.getVisitsByStudentId(studentId, jwtUser);
    List<StudentPaymentResponse> studentPayments =
        studentPaymentSpi.getStudentPaymentsByStudentId(studentId, jwtUser);
    List<LessonResponse> allLessons =
        (groupId != null) ? lessonSpi.getLessonsByGroupId(groupId, jwtUser) : List.of();

    Set<StudentStatus> studentStatuses =
        studentStatusService.getStudentStatuses(
            studentVisits, studentPayments, lastGroupLesson.orElse(null));

    List<VisitWithLessonResponse> visitsWithLessons =
        studentVisits.stream()
            .map(
                visit ->
                    new VisitWithLessonResponse(
                        visit,
                        allLessons.stream()
                            .filter(lesson -> lesson.id().equals(visit.lessonId()))
                            .findFirst()
                            .orElse(null)))
            .toList();

    return new StudentDetailsResponse(
        student,
        visitsWithLessons,
        studentPayments,
        studentStatuses,
        studentGroup,
        optionalGroupStudentResponse.orElse(null));
  }

  @Transactional
  public StudentResponse createStudent(CreateStudentRequest request, JwtUser jwtUser) {
    log.info("Creating student: {}", request);

    Student student = studentMapper.toStudent(request, jwtUser.userId());

    Student savedStudent = saveStudent(student);

    if (request.groupId() != null) {
      groupStudentSpi.addStudentToGroup(
          savedStudent.getId(), request.groupId(), request.joinedAt(), jwtUser);

      visitSpi.syncStudentVisits(
          savedStudent.getId(), request.groupId(), request.joinedAt(), jwtUser);
    }

    return studentMapper.toResponse(savedStudent);
  }

  @Transactional
  public StudentResponse updateStudent(
      UUID studentId, Map<String, Object> updates, JwtUser jwtUser) {
    log.info("Updating student: {}", studentId);

    final String JOINED_AT = "joinedAt";
    final String GROUP_ID = "groupId";

    Student student =
        studentRepository
            .findByIdAndOwnerId(studentId, jwtUser.userId())
            .orElseThrow(() -> new EntityNotFoundException("Student not found"));

    GroupStudentResponse currentLink =
        groupStudentSpi.getGroupsByStudentId(studentId, jwtUser).stream().findFirst().orElse(null);

    UUID currentGroupId = currentLink != null ? currentLink.groupId() : null;

    OffsetDateTime newJoinedAt =
        updates.containsKey(JOINED_AT)
            ? OffsetDateTime.parse(updates.get(JOINED_AT).toString())
            : OffsetDateTime.now();

    if (updates.containsKey(GROUP_ID)) {
      Object rawId = updates.get(GROUP_ID);
      UUID newGroupId = rawId != null ? UUID.fromString(rawId.toString()) : null;

      if (currentGroupId != null && !currentGroupId.equals(newGroupId)) {
        groupStudentSpi.removeStudentFromGroup(studentId, currentGroupId, jwtUser);
      }

      if (newGroupId != null && !newGroupId.equals(currentGroupId)) {
        groupStudentSpi.addStudentToGroup(studentId, newGroupId, newJoinedAt, jwtUser);
        visitSpi.syncStudentVisits(studentId, newGroupId, newJoinedAt, jwtUser);
      }
    } else if (updates.containsKey(JOINED_AT)
        && currentGroupId != null
        && !newJoinedAt.equals(currentLink.joinedAt())) {
      groupStudentSpi.removeStudentFromGroup(studentId, currentGroupId, jwtUser);
      groupStudentSpi.addStudentToGroup(studentId, currentGroupId, newJoinedAt, jwtUser);
      visitSpi.syncStudentVisits(studentId, currentGroupId, newJoinedAt, jwtUser);
    }

    Student updatedStudent = studentMapper.updateStudent(student, updates);
    return studentMapper.toResponse(saveStudent(updatedStudent));
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

  @Transactional
  public void deleteStudentPayment(UUID paymentId, JwtUser jwtUser) {
    studentPaymentSpi.deleteStudentPaymentById(paymentId, jwtUser);
  }

  private Student saveStudent(Student student) {
    log.info("Saving student: {}", student);
    return studentRepository.saveAndFlush(student);
  }
}
