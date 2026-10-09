package org.trenero.backend.student.internal.service;

import static org.trenero.backend.common.exception.ExceptionUtils.entityNotFoundSupplier;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.Executor;
import java.util.stream.Collectors;
import lombok.NonNull;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Lazy;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.trenero.backend.common.async.AsyncUtils;
import org.trenero.backend.common.security.JwtUser;
import org.trenero.backend.group.external.response.GroupResponse;
import org.trenero.backend.group.external.response.GroupStudentResponse;
import org.trenero.backend.group.external.spi.GroupSpi;
import org.trenero.backend.group.external.spi.GroupStudentSpi;
import org.trenero.backend.lesson.external.response.LessonResponse;
import org.trenero.backend.lesson.external.spi.LessonSpi;
import org.trenero.backend.student.external.response.StudentResponse;
import org.trenero.backend.student.external.response.StudentWithStatusesResponse;
import org.trenero.backend.student.external.spi.StudentSpi;
import org.trenero.backend.student.internal.domain.Student;
import org.trenero.backend.student.internal.mapper.StudentMapper;
import org.trenero.backend.student.internal.repository.StudentRepository;
import org.trenero.backend.student.internal.request.CreateStudentPaymentRequest;
import org.trenero.backend.student.internal.request.CreateStudentRequest;
import org.trenero.backend.student.internal.response.StudentSummaryResponse;
import org.trenero.backend.student.internal.response.VisitWithLessonResponse;
import org.trenero.backend.transaction.external.response.TransactionResponse;
import org.trenero.backend.transaction.external.spi.TransactionSpi;
import org.trenero.backend.visit.external.spi.VisitSpi;

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
  @Lazy private final TransactionSpi transactionSpi;
  @Lazy private final VisitSpi visitSpi;
  @Lazy private final LessonSpi lessonSpi;

  private final Executor executor;

  @Transactional(readOnly = true)
  public @NonNull List<StudentResponse> getAllStudents(@NonNull JwtUser jwtUser) {
    log.info("Getting all students: user={}", jwtUser);
    return studentRepository.findAllByOwnerId(jwtUser.id()).stream()
        .map(studentMapper::toResponse)
        .toList();
  }

  @Transactional(readOnly = true)
  public @NonNull List<StudentSummaryResponse> getStudentsSummary(@NonNull JwtUser jwtUser) {
    log.info("Getting students overview: user={}", jwtUser);

    var students = self.getAllStudents(jwtUser);

    if (students.isEmpty()) {
      return List.of();
    }

    var studentIds = students.stream().map(StudentResponse::getId).toList();

    var visitsFuture =
        CompletableFuture.supplyAsync(
            () -> visitSpi.getVisitsByStudentIds(studentIds, jwtUser), executor);

    var paymentsFuture =
        CompletableFuture.supplyAsync(
            () -> transactionSpi.getTransactionsByStudentIds(studentIds, jwtUser), executor);

    var groupLinksFuture =
        CompletableFuture.supplyAsync(
            () -> groupStudentSpi.getGroupStudentsByStudentIds(studentIds, jwtUser), executor);

    var groupIdsFuture =
        groupLinksFuture.thenApply(
            links ->
                links.values().stream().map(GroupStudentResponse::getGroupId).distinct().toList());

    var groupsFuture =
        groupIdsFuture.thenComposeAsync(
            groupIds -> {
              if (groupIds.isEmpty()) {
                return CompletableFuture.completedFuture(Map.<UUID, GroupResponse>of());
              }
              return CompletableFuture.supplyAsync(
                  () -> groupSpi.getGroupsByIds(groupIds, jwtUser), executor);
            },
            executor);

    var groupLessonsFuture =
        groupIdsFuture.thenComposeAsync(
            groupIds -> {
              if (groupIds.isEmpty()) {
                return CompletableFuture.completedFuture(Map.<UUID, LessonResponse>of());
              }
              return CompletableFuture.supplyAsync(
                  () -> lessonSpi.getLastGroupLessonsByGroupIds(groupIds, jwtUser), executor);
            },
            executor);

    AsyncUtils.awaitAll(
        visitsFuture, paymentsFuture, groupLinksFuture, groupsFuture, groupLessonsFuture);

    var visitsMap = visitsFuture.join();
    var paymentsMap = paymentsFuture.join();
    var studentToGroupLinkMap = groupLinksFuture.join();
    var groupsMap = groupsFuture.join();
    var groupLessonMap = groupLessonsFuture.join();

    return students.stream()
        .map(
            student -> {
              var link = studentToGroupLinkMap.get(student.getId());
              var groupId = (link != null) ? link.getGroupId() : null;

              var studentVisits = visitsMap.getOrDefault(student.getId(), List.of());
              var studentPayments = paymentsMap.getOrDefault(student.getId(), List.of());
              var lastLesson = (groupId != null) ? groupLessonMap.get(groupId) : null;

              var statuses =
                  studentStatusService.getStudentStatuses(
                      studentVisits, studentPayments, lastLesson);

              var group = (groupId != null) ? groupsMap.get(groupId) : null;

              return new StudentSummaryResponse(student, group, statuses);
            })
        .toList();
  }

  @Transactional(readOnly = true)
  public @NonNull StudentResponse getStudentById(
      @NonNull UUID studentId, @NonNull JwtUser jwtUser) {
    log.info("Getting student by id: studentId={}; user={}", studentId, jwtUser);
    return studentRepository
        .findByIdAndOwnerId(studentId, jwtUser.id())
        .map(studentMapper::toResponse)
        .orElseThrow(entityNotFoundSupplier(Student.class, studentId, jwtUser));
  }

  @Transactional(readOnly = true)
  public @NonNull List<VisitWithLessonResponse> getStudentVisits(
      @NonNull UUID studentId, @NonNull JwtUser jwtUser) {
    log.info("Getting visits for studentId={}; user={}", studentId, jwtUser);

    var studentVisits = visitSpi.getVisitsByStudentId(studentId, jwtUser);

    // A student is marked for the lessons of every group they belong to and for
    // the lessons that are stored for them alone, so each lesson the visits
    // point to is loaded, whether it belongs to a group or not.
    var lessonIds = studentVisits.stream().map(visit -> visit.getLessonId()).distinct().toList();

    var lessonsMap = lessonSpi.getLessonsByIds(lessonIds, jwtUser);

    return studentVisits.stream()
        .filter(visit -> lessonsMap.containsKey(visit.getLessonId()))
        .map(visit -> new VisitWithLessonResponse(visit, lessonsMap.get(visit.getLessonId())))
        .toList();
  }

  @Transactional(readOnly = true)
  public @NonNull List<TransactionResponse> getStudentPayments(
      @NonNull UUID studentId, @NonNull JwtUser jwtUser) {
    log.info("Getting payments for studentId={}; user={}", studentId, jwtUser);
    return transactionSpi.getTransactionsByStudentId(studentId, jwtUser);
  }

  @Transactional(readOnly = true)
  public @NonNull Map<UUID, StudentResponse> getStudentsByIds(
      @NonNull List<UUID> studentIds, @NonNull JwtUser jwtUser) {
    log.info("Getting students by ids: studentIds={}; user={}", studentIds, jwtUser);
    return studentRepository.findAllByIdsAndOwnerId(studentIds, jwtUser.id()).stream()
        .map(studentMapper::toResponse)
        .collect(
            Collectors.toMap(
                StudentResponse::getId, student -> student, (existing, _) -> existing));
  }

  @Transactional
  public @NonNull StudentResponse createStudent(
      @NonNull CreateStudentRequest request, @NonNull JwtUser jwtUser) {
    log.info("Creating student: request={}; user={}", request, jwtUser);

    var student = studentMapper.toStudent(request, jwtUser.id());
    var savedStudent = self.saveStudent(student);

    return studentMapper.toResponse(savedStudent);
  }

  @Transactional
  public @NonNull TransactionResponse createStudentPayment(
      @NonNull UUID studentId,
      @NonNull CreateStudentPaymentRequest request,
      @NonNull JwtUser jwtUser) {
    log.info(
        "Creating payment: studentId={}; request={}; user={}", studentId, request, jwtUser.id());

    return transactionSpi.createStudentPayment(
        studentId, request.getAmount(), request.getDate(), request.getPaidUntil(), jwtUser);
  }

  @Transactional
  public @NonNull StudentResponse updateStudent(
      @NonNull UUID studentId, @NonNull Map<String, Object> updates, @NonNull JwtUser jwtUser) {
    log.info("Updating student: studentId={}; updates={}; user={}", studentId, updates, jwtUser);

    var student =
        studentRepository
            .findByIdAndOwnerId(studentId, jwtUser.id())
            .orElseThrow(entityNotFoundSupplier(Student.class, studentId, jwtUser));

    if (updates.containsKey("groupId")) {
      var optionalGroupStudentResponse =
          groupStudentSpi.getGroupsByStudentId(studentId, jwtUser).stream().findFirst();

      optionalGroupStudentResponse.ifPresent(
          groupStudentResponse ->
              groupStudentSpi.removeStudentFromGroup(
                  studentId, groupStudentResponse.getGroupId(), jwtUser));

      var rawGroupId = updates.get("groupId");

      if (rawGroupId != null && !rawGroupId.toString().isBlank()) {
        var groupId = UUID.fromString(rawGroupId.toString());
        groupStudentSpi.addStudentToGroup(
            studentId, groupId, parseJoinedAt(updates.get("joinedAt")), jwtUser);
      }
    }

    var updatedStudent = studentMapper.updateStudent(student, updates);
    var savedStudent = self.saveStudent(updatedStudent);

    return studentMapper.toResponse(savedStudent);
  }

  /**
   * The day the student joined the group, sent by the group sheet as a plain ISO date. A missing
   * value lets the group module fall back to the current day.
   */
  private static LocalDate parseJoinedAt(Object rawJoinedAt) {
    if (rawJoinedAt == null || rawJoinedAt.toString().isBlank()) {
      return null;
    }

    return LocalDate.parse(rawJoinedAt.toString());
  }

  @Override
  @Transactional(readOnly = true)
  public @NonNull Map<UUID, StudentWithStatusesResponse> getStudentsWithStatusesByIds(
      @NonNull List<UUID> studentIds, @NonNull JwtUser jwtUser) {
    log.info("Getting students with statuses by ids: studentIds={}; user={}", studentIds, jwtUser);

    if (studentIds.isEmpty()) {
      return Map.of();
    }

    var studentsMap = getStudentsByIds(studentIds, jwtUser);
    if (studentsMap.isEmpty()) {
      return Map.of();
    }

    var distinctStudentIds = studentsMap.keySet().stream().toList();

    var visitsFuture =
        CompletableFuture.supplyAsync(
            () -> visitSpi.getVisitsByStudentIds(distinctStudentIds, jwtUser), executor);

    var paymentsFuture =
        CompletableFuture.supplyAsync(
            () -> transactionSpi.getTransactionsByStudentIds(distinctStudentIds, jwtUser),
            executor);

    var groupLinksFuture =
        CompletableFuture.supplyAsync(
            () -> groupStudentSpi.getGroupStudentsByStudentIds(distinctStudentIds, jwtUser),
            executor);

    var groupLessonsFuture =
        groupLinksFuture.thenComposeAsync(
            links -> {
              var groupIds =
                  links.values().stream().map(GroupStudentResponse::getGroupId).distinct().toList();

              if (groupIds.isEmpty()) {
                return CompletableFuture.completedFuture(Map.<UUID, LessonResponse>of());
              }
              return CompletableFuture.supplyAsync(
                  () -> lessonSpi.getLastGroupLessonsByGroupIds(groupIds, jwtUser), executor);
            },
            executor);

    AsyncUtils.awaitAll(visitsFuture, paymentsFuture, groupLinksFuture, groupLessonsFuture);

    var visitsMap = visitsFuture.join();
    var paymentsMap = paymentsFuture.join();
    var studentToGroupLinkMap = groupLinksFuture.join();
    var groupLessonMap = groupLessonsFuture.join();

    return studentsMap.values().stream()
        .collect(
            Collectors.toMap(
                StudentResponse::getId,
                student -> {
                  var link = studentToGroupLinkMap.get(student.getId());
                  var groupId = (link != null) ? link.getGroupId() : null;

                  var studentVisits = visitsMap.getOrDefault(student.getId(), List.of());
                  var studentPayments = paymentsMap.getOrDefault(student.getId(), List.of());
                  var lastLesson = (groupId != null) ? groupLessonMap.get(groupId) : null;

                  var statuses =
                      studentStatusService.getStudentStatuses(
                          studentVisits, studentPayments, lastLesson);

                  return new StudentWithStatusesResponse(student, statuses);
                },
                (existing, _) -> existing));
  }

  @Transactional
  public void deleteStudent(@NonNull UUID studentId, @NonNull JwtUser jwtUser) {
    log.info("Deleting student: studentId={}; user={}", studentId, jwtUser);

    Student student =
        studentRepository
            .findByIdAndOwnerId(studentId, jwtUser.id())
            .orElseThrow(entityNotFoundSupplier(Student.class, studentId, jwtUser));

    studentRepository.delete(student);
  }

  @Transactional
  public @NonNull Student saveStudent(@NonNull Student student) {
    log.info("Saving student: student={}", student);
    return studentRepository.saveAndFlush(student);
  }
}
