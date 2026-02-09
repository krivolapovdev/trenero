package org.trenero.backend.student.internal.service;

import static org.trenero.backend.common.exception.ExceptionUtils.entityNotFoundSupplier;

import java.time.OffsetDateTime;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Set;
import java.util.UUID;
import java.util.function.Function;
import java.util.stream.Collectors;
import lombok.NonNull;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Lazy;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.trenero.backend.common.response.GroupResponse;
import org.trenero.backend.common.response.GroupStudentResponse;
import org.trenero.backend.common.response.LessonResponse;
import org.trenero.backend.common.response.StudentPaymentResponse;
import org.trenero.backend.common.response.StudentResponse;
import org.trenero.backend.common.response.VisitResponse;
import org.trenero.backend.common.security.JwtUser;
import org.trenero.backend.group.external.GroupSpi;
import org.trenero.backend.group.external.GroupStudentSpi;
import org.trenero.backend.lesson.external.LessonSpi;
import org.trenero.backend.payment.external.StudentPaymentSpi;
import org.trenero.backend.student.external.StudentSpi;
import org.trenero.backend.student.internal.domain.Student;
import org.trenero.backend.student.internal.domain.StudentStatus;
import org.trenero.backend.student.internal.mapper.StudentMapper;
import org.trenero.backend.student.internal.repository.StudentRepository;
import org.trenero.backend.student.internal.request.CreateStudentRequest;
import org.trenero.backend.student.internal.response.StudentDetailsResponse;
import org.trenero.backend.student.internal.response.StudentOverviewResponse;
import org.trenero.backend.student.internal.response.VisitWithLessonResponse;
import org.trenero.backend.visit.external.VisitSpi;

@Service
@RequiredArgsConstructor
@Slf4j
public class StudentService implements StudentSpi {
  private final StudentRepository studentRepository;
  private final StudentMapper studentMapper;

  @Lazy private final StudentService self;
  @Lazy private final StudentStatusService studentStatusService;
  @Lazy private final GroupSpi groupSpi;
  @Lazy private final GroupStudentSpi groupStudentSpi;
  @Lazy private final StudentPaymentSpi studentPaymentSpi;
  @Lazy private final VisitSpi visitSpi;
  @Lazy private final LessonSpi lessonSpi;

  @Transactional(readOnly = true)
  public @NonNull List<StudentResponse> getAllStudents(@NonNull JwtUser jwtUser) {
    log.info("Getting all students: user={}", jwtUser);
    return studentRepository.findAllByOwnerId(jwtUser.userId()).stream()
        .map(studentMapper::toResponse)
        .toList();
  }

  @Transactional(readOnly = true)
  public List<StudentOverviewResponse> getStudentsOverview(JwtUser jwtUser) {
    log.info("Getting students overview: user={}", jwtUser);

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
  public @NonNull StudentResponse getStudentById(
      @NonNull UUID studentId, @NonNull JwtUser jwtUser) {
    log.info("Getting student by id: studentId={}; user={}", studentId, jwtUser);
    return studentRepository
        .findByIdAndOwnerId(studentId, jwtUser.userId())
        .map(studentMapper::toResponse)
        .orElseThrow(entityNotFoundSupplier(Student.class, studentId, jwtUser));
  }

  @Transactional(readOnly = true)
  public @NonNull Map<UUID, List<StudentResponse>> getStudentsByIds(
      @NonNull List<UUID> studentIds, @NonNull JwtUser jwtUser) {
    log.info("Getting students by ids: studentIds={}; user={}", studentIds, jwtUser);
    return studentRepository.findAllByIdsAndOwnerId(studentIds, jwtUser.userId()).stream()
        .map(studentMapper::toResponse)
        .collect(Collectors.groupingBy(StudentResponse::id));
  }

  @Transactional(readOnly = true)
  public StudentDetailsResponse getStudentDetailsById(UUID studentId, JwtUser jwtUser) {
    log.info("Getting student details by id: studentId={}; user={}", studentId, jwtUser);

    var student = self.getStudentById(studentId, jwtUser);

    var groupStudentResponse =
        groupStudentSpi.getGroupsByStudentId(studentId, jwtUser).stream().findFirst();

    var groupId = groupStudentResponse.map(GroupStudentResponse::groupId);

    var groupResponse = groupId.map(id -> groupSpi.getGroupById(id, jwtUser));

    var groupLessons =
        groupId.map(id -> lessonSpi.getLessonsByGroupId(id, jwtUser)).orElse(List.of());

    var lessonsMap =
        groupLessons.stream().collect(Collectors.toMap(LessonResponse::id, Function.identity()));

    var studentVisits = visitSpi.getVisitsByStudentId(studentId, jwtUser);

    var lastGroupLesson = groupLessons.stream().max(Comparator.comparing(LessonResponse::date));

    var studentPayments = studentPaymentSpi.getStudentPaymentsByStudentId(studentId, jwtUser);

    var studentStatuses =
        studentStatusService.getStudentStatuses(
            studentVisits, studentPayments, lastGroupLesson.orElse(null));

    var visitsWithLessons =
        studentVisits.stream()
            .filter(visit -> lessonsMap.containsKey(visit.lessonId()))
            .map(visit -> new VisitWithLessonResponse(visit, lessonsMap.get(visit.lessonId())))
            .toList();

    return new StudentDetailsResponse(
        student,
        visitsWithLessons,
        studentPayments,
        studentStatuses,
        groupResponse.orElse(null),
        groupStudentResponse.orElse(null));
  }

  @Transactional
  public StudentResponse createStudent(CreateStudentRequest request, JwtUser jwtUser) {
    log.info("Creating student: request={}; user={}", request, jwtUser);

    Student student = studentMapper.toStudent(request, jwtUser.userId());

    Student savedStudent = self.saveStudent(student);

    if (request.groupId() != null) {
      groupStudentSpi.addStudentToGroup(savedStudent.getId(), request.groupId(), jwtUser);
    }

    return studentMapper.toResponse(savedStudent);
  }

  @Transactional
  public StudentResponse updateStudent(
      UUID studentId, Map<String, Object> updates, JwtUser jwtUser) {
    log.info("Updating student: studentId={}; updates={}; user={}", studentId, updates, jwtUser);

    Student student =
        studentRepository
            .findByIdAndOwnerId(studentId, jwtUser.userId())
            .orElseThrow(entityNotFoundSupplier(Student.class, studentId, jwtUser));

    if (updates.containsKey("groupId")) {

      Optional<GroupStudentResponse> optionalGroupStudentResponse =
          groupStudentSpi.getGroupsByStudentId(studentId, jwtUser).stream().findFirst();

      optionalGroupStudentResponse.ifPresent(
          groupStudentResponse ->
              groupStudentSpi.removeStudentFromGroup(
                  studentId, groupStudentResponse.groupId(), jwtUser));

      Object rawGroupId = updates.get("groupId");

      if (rawGroupId != null && !rawGroupId.toString().isBlank()) {
        UUID groupId = UUID.fromString(rawGroupId.toString());
        groupStudentSpi.addStudentToGroup(studentId, groupId, jwtUser);
      }
    }

    Student updatedStudent = studentMapper.updateStudent(student, updates);
    Student savedStudent = self.saveStudent(updatedStudent);

    return studentMapper.toResponse(savedStudent);
  }

  @Transactional
  public void softDeleteStudent(UUID studentId, JwtUser jwtUser) {
    log.info("Deleting student: studentId={}; user={}", studentId, jwtUser);

    studentRepository
        .findByIdAndOwnerId(studentId, jwtUser.userId())
        .map(
            student -> {
              student.setDeletedAt(OffsetDateTime.now());
              return self.saveStudent(student);
            })
        .orElseThrow(entityNotFoundSupplier(Student.class, studentId, jwtUser));
  }

  @Transactional
  public Student saveStudent(Student student) {
    log.info("Saving student: student={}", student);
    return studentRepository.saveAndFlush(student);
  }
}
