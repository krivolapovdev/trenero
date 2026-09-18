package org.trenero.backend.student.internal.service;

import static org.trenero.backend.common.exception.ExceptionUtils.entityNotFoundSupplier;

import java.time.OffsetDateTime;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.Executor;
import java.util.function.Function;
import java.util.stream.Collectors;
import lombok.NonNull;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Lazy;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.trenero.backend.common.async.AsyncUtils;
import org.trenero.backend.common.response.GroupResponse;
import org.trenero.backend.common.response.GroupStudentResponse;
import org.trenero.backend.common.response.LessonResponse;
import org.trenero.backend.common.response.StudentResponse;
import org.trenero.backend.common.security.JwtUser;
import org.trenero.backend.group.external.GroupSpi;
import org.trenero.backend.group.external.GroupStudentSpi;
import org.trenero.backend.lesson.external.LessonSpi;
import org.trenero.backend.payment.external.StudentPaymentSpi;
import org.trenero.backend.student.external.StudentSpi;
import org.trenero.backend.student.internal.domain.Student;
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

  private final Executor executor;

  @Transactional(readOnly = true)
  public @NonNull List<StudentResponse> getAllStudents(@NonNull JwtUser jwtUser) {
    log.info("Getting all students: user={}", jwtUser);
    return studentRepository.findAllByOwnerId(jwtUser.id()).stream()
        .map(studentMapper::toResponse)
        .toList();
  }

  @Transactional(readOnly = true)
  public @NonNull List<StudentOverviewResponse> getStudentsOverview(@NonNull JwtUser jwtUser) {
    log.info("Getting students overview: user={}", jwtUser);

    // 1. Fetch all students sequentially
    var students = self.getAllStudents(jwtUser);

    if (students.isEmpty()) {
      return List.of();
    }

    var studentIds = students.stream().map(StudentResponse::id).toList();

    // 2. Launch Level 1 Parallel Tasks
    var visitsFuture =
        CompletableFuture.supplyAsync(
            () -> visitSpi.getVisitsByStudentIds(studentIds, jwtUser), executor);

    var paymentsFuture =
        CompletableFuture.supplyAsync(
            () -> studentPaymentSpi.getStudentPaymentsByStudentIds(studentIds, jwtUser), executor);

    var groupLinksFuture =
        CompletableFuture.supplyAsync(
            () -> groupStudentSpi.getGroupStudentsByStudentIds(studentIds, jwtUser), executor);

    // 3. Extract group IDs quickly once groupLinksFuture completes
    var groupIdsFuture =
        groupLinksFuture.thenApply(
            links ->
                links.values().stream().map(GroupStudentResponse::groupId).distinct().toList());

    // 4. Chain Level 2 Parallel Tasks (Depend on groupIds)
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

    // 5. Await all background tasks simultaneously
    AsyncUtils.awaitAll(
        visitsFuture, paymentsFuture, groupLinksFuture, groupsFuture, groupLessonsFuture);

    // 6. Extract values
    var visitsMap = visitsFuture.join();
    var paymentsMap = paymentsFuture.join();
    var studentToGroupLinkMap = groupLinksFuture.join();
    var groupsMap = groupsFuture.join();
    var groupLessonMap = groupLessonsFuture.join();

    // 7. Perform fast in-memory assembly
    return students.stream()
        .map(
            student -> {
              var link = studentToGroupLinkMap.get(student.id());
              var groupId = (link != null) ? link.groupId() : null;

              var studentVisits = visitsMap.getOrDefault(student.id(), List.of());
              var studentPayments = paymentsMap.getOrDefault(student.id(), List.of());
              var lastLesson = (groupId != null) ? groupLessonMap.get(groupId) : null;

              var statuses =
                  studentStatusService.getStudentStatuses(
                      studentVisits, studentPayments, lastLesson);

              var group = (groupId != null) ? groupsMap.get(groupId) : null;

              return new StudentOverviewResponse(student, group, statuses);
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
  public @NonNull Map<UUID, List<StudentResponse>> getStudentsByIds(
      @NonNull List<UUID> studentIds, @NonNull JwtUser jwtUser) {
    log.info("Getting students by ids: studentIds={}; user={}", studentIds, jwtUser);
    return studentRepository.findAllByIdsAndOwnerId(studentIds, jwtUser.id()).stream()
        .map(studentMapper::toResponse)
        .collect(Collectors.groupingBy(StudentResponse::id));
  }

  @Transactional(readOnly = true)
  public @NonNull StudentDetailsResponse getStudentDetailsById(
      @NonNull UUID studentId, @NonNull JwtUser jwtUser) {
    log.info("Getting student details by id: studentId={}; user={}", studentId, jwtUser);

    // 1. Launch independent queries in parallel threads
    var studentFuture =
        CompletableFuture.supplyAsync(() -> getStudentById(studentId, jwtUser), executor);

    var visitsFuture =
        CompletableFuture.supplyAsync(
            () -> visitSpi.getVisitsByStudentId(studentId, jwtUser), executor);

    var paymentsFuture =
        CompletableFuture.supplyAsync(
            () -> studentPaymentSpi.getStudentPaymentsByStudentId(studentId, jwtUser), executor);

    var groupStudentFuture =
        CompletableFuture.supplyAsync(
            () -> groupStudentSpi.getGroupsByStudentId(studentId, jwtUser).stream().findFirst(),
            executor);

    // 2. Chain dependent queries
    var groupFuture =
        groupStudentFuture.thenComposeAsync(
            groupOpt ->
                groupOpt
                    .map(
                        gs ->
                            CompletableFuture.supplyAsync(
                                () -> groupSpi.getGroupById(gs.groupId(), jwtUser), executor))
                    .orElse(CompletableFuture.completedFuture(null)),
            executor);

    var lessonsFuture =
        groupStudentFuture.thenComposeAsync(
            groupOpt ->
                groupOpt
                    .map(
                        gs ->
                            CompletableFuture.supplyAsync(
                                () -> lessonSpi.getLessonsByGroupId(gs.groupId(), jwtUser),
                                executor))
                    .orElse(CompletableFuture.completedFuture(List.of())),
            executor);

    // 3. Await all background tasks simultaneously
    AsyncUtils.awaitAll(studentFuture, visitsFuture, paymentsFuture, groupFuture, lessonsFuture);

    // 4. Extract values
    var student = studentFuture.join();
    var studentVisits = visitsFuture.join();
    var studentPayments = paymentsFuture.join();
    var groupStudentOpt = groupStudentFuture.join();
    var groupResponse = groupFuture.join();
    var groupLessons = lessonsFuture.join();

    // 5. Perform fast in-memory mapping
    var lessonsMap =
        groupLessons.stream()
            .collect(Collectors.toMap(LessonResponse::id, Function.identity(), (l1, l2) -> l1));

    var lastGroupLesson =
        groupLessons.stream().max(Comparator.comparing(LessonResponse::date)).orElse(null);

    var studentStatuses =
        studentStatusService.getStudentStatuses(studentVisits, studentPayments, lastGroupLesson);

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
        groupResponse,
        groupStudentOpt.orElse(null));
  }

  @Transactional
  public @NonNull StudentResponse createStudent(
      @NonNull CreateStudentRequest request, @NonNull JwtUser jwtUser) {
    log.info("Creating student: request={}; user={}", request, jwtUser);

    var student = studentMapper.toStudent(request, jwtUser.id());
    var savedStudent = self.saveStudent(student);

    if (request.groupId() != null) {
      groupStudentSpi.addStudentToGroup(savedStudent.getId(), request.groupId(), jwtUser);
    }

    return studentMapper.toResponse(savedStudent);
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
                  studentId, groupStudentResponse.groupId(), jwtUser));

      var rawGroupId = updates.get("groupId");

      if (rawGroupId != null && !rawGroupId.toString().isBlank()) {
        var groupId = UUID.fromString(rawGroupId.toString());
        groupStudentSpi.addStudentToGroup(studentId, groupId, jwtUser);
      }
    }

    var updatedStudent = studentMapper.updateStudent(student, updates);
    var savedStudent = self.saveStudent(updatedStudent);

    return studentMapper.toResponse(savedStudent);
  }

  @Transactional
  public void softDeleteStudent(@NonNull UUID studentId, @NonNull JwtUser jwtUser) {
    log.info("Deleting student: studentId={}; user={}", studentId, jwtUser);

    studentRepository
        .findByIdAndOwnerId(studentId, jwtUser.id())
        .map(
            student -> {
              student.setDeletedAt(OffsetDateTime.now());
              return self.saveStudent(student);
            })
        .orElseThrow(entityNotFoundSupplier(Student.class, studentId, jwtUser));
  }

  @Transactional
  public @NonNull Student saveStudent(@NonNull Student student) {
    log.info("Saving student: student={}", student);
    return studentRepository.saveAndFlush(student);
  }
}
