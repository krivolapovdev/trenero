package org.trenero.backend.student.internal.service;

import static org.trenero.backend.common.exception.ExceptionUtils.entityNotFoundSupplier;

import java.time.OffsetDateTime;
import java.util.Collection;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.UUID;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.Executor;
import java.util.stream.Collectors;
import lombok.NonNull;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Lazy;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;
import org.trenero.backend.common.async.AsyncUtils;
import org.trenero.backend.common.exception.ApiErrorCode;
import org.trenero.backend.common.exception.ConflictException;
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
import org.trenero.backend.visit.external.response.VisitResponse;
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
                links.values().stream()
                    .flatMap(List::stream)
                    .map(GroupStudentResponse::getGroupId)
                    .distinct()
                    .toList());

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

    var lessonsFuture =
        visitsFuture.thenComposeAsync(
            visits -> {
              var lessonIds =
                  visits.values().stream()
                      .flatMap(List::stream)
                      .map(VisitResponse::getLessonId)
                      .distinct()
                      .toList();

              if (lessonIds.isEmpty()) {
                return CompletableFuture.completedFuture(Map.<UUID, LessonResponse>of());
              }
              return CompletableFuture.supplyAsync(
                  () -> lessonSpi.getLessonsByIds(lessonIds, jwtUser), executor);
            },
            executor);

    AsyncUtils.awaitAll(
        visitsFuture, paymentsFuture, groupLinksFuture, groupsFuture, lessonsFuture);

    var visitsMap = visitsFuture.join();
    var paymentsMap = paymentsFuture.join();
    var studentToGroupLinksMap = groupLinksFuture.join();
    var groupsMap = groupsFuture.join();
    var lessonsMap = lessonsFuture.join();

    return students.stream()
        .map(
            student -> {
              var links = studentToGroupLinksMap.getOrDefault(student.getId(), List.of());
              var studentGroups =
                  links.stream()
                      .map(link -> groupsMap.get(link.getGroupId()))
                      .filter(Objects::nonNull)
                      .toList();

              var studentVisits = visitsMap.getOrDefault(student.getId(), List.of());
              var studentPayments = paymentsMap.getOrDefault(student.getId(), List.of());
              var studentLessons =
                  studentVisits.stream()
                      .map(VisitResponse::getLessonId)
                      .distinct()
                      .map(lessonsMap::get)
                      .filter(Objects::nonNull)
                      .toList();

              var statuses =
                  studentStatusService.getStudentStatuses(
                      studentVisits, studentPayments, studentLessons, student.getFree());

              return new StudentSummaryResponse(student, statuses, studentGroups);
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
      @NonNull UUID studentId, OffsetDateTime from, OffsetDateTime to, @NonNull JwtUser jwtUser) {
    log.info(
        "Getting visits for studentId={}; from={}; to={}; user={}", studentId, from, to, jwtUser);

    var studentVisits = visitSpi.getVisitsByStudentId(studentId, jwtUser);

    var lessonIds = studentVisits.stream().map(VisitResponse::getLessonId).distinct().toList();

    var lessonsMap = lessonSpi.getLessonsByIds(lessonIds, jwtUser);

    return studentVisits.stream()
        .filter(visit -> lessonsMap.containsKey(visit.getLessonId()))
        .map(visit -> new VisitWithLessonResponse(visit, lessonsMap.get(visit.getLessonId())))
        .filter(response -> isWithin(response.getLesson().getDate(), from, to))
        .toList();
  }

  private static boolean isWithin(OffsetDateTime date, OffsetDateTime from, OffsetDateTime to) {
    return (from == null || !date.isBefore(from)) && (to == null || !date.isAfter(to));
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

    String fullName = requireTrimmedFullName(request.fullName());
    requireFreeFullName(fullName, null, jwtUser);

    var student = studentMapper.toStudent(request, jwtUser.id());
    // The mapper copies the name as it was sent; the row keeps the trimmed one.
    student.setFullName(fullName);

    var savedStudent = self.saveStudent(student);

    return studentMapper.toResponse(savedStudent);
  }

  /**
   * The name of a student is the only handle they have on every page, so a patch that carries a
   * name has to carry a usable one. The value is trimmed, so that two names that differ in nothing
   * but surrounding blanks are recognized as the same name by {@link #requireFreeFullName}.
   */
  private static @NonNull String requireTrimmedFullName(Object fullName) {
    if (!(fullName instanceof String text) || text.isBlank()) {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "fullName must not be blank");
    }

    return text.trim();
  }

  private void requireFreeFullName(String fullName, UUID studentId, JwtUser jwtUser) {
    boolean taken =
        studentId == null
            ? studentRepository.existsByOwnerIdAndFullName(jwtUser.id(), fullName)
            : studentRepository.existsByOwnerIdAndFullNameAndIdNot(
                jwtUser.id(), fullName, studentId);

    if (taken) {
      throw new ConflictException(
          ApiErrorCode.STUDENT_NAME_NOT_UNIQUE,
          "A student named \"%s\" already exists".formatted(fullName));
    }
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

    Map<String, Object> patch = new LinkedHashMap<>(updates);

    if (patch.containsKey("fullName")) {
      String fullName = requireTrimmedFullName(patch.get("fullName"));
      requireFreeFullName(fullName, studentId, jwtUser);
      patch.put("fullName", fullName);
    }

    if (patch.containsKey("groupIds") || patch.containsKey("groupId")) {
      reconcileStudentGroups(studentId, patch, jwtUser);
    }

    var updatedStudent = studentMapper.updateStudent(student, patch);
    var savedStudent = self.saveStudent(updatedStudent);

    return studentMapper.toResponse(savedStudent);
  }

  private void reconcileStudentGroups(
      UUID studentId, Map<String, Object> updates, JwtUser jwtUser) {
    var requestedGroupIds = parseRequestedGroupIds(updates);
    var currentGroupIds =
        groupStudentSpi.getGroupsByStudentId(studentId, jwtUser).stream()
            .map(GroupStudentResponse::getGroupId)
            .collect(Collectors.toSet());

    currentGroupIds.stream()
        .filter(groupId -> !requestedGroupIds.contains(groupId))
        .forEach(groupId -> groupStudentSpi.removeStudentFromGroup(studentId, groupId, jwtUser));

    requestedGroupIds.stream()
        .filter(groupId -> !currentGroupIds.contains(groupId))
        .forEach(groupId -> groupStudentSpi.addStudentToGroup(studentId, groupId, jwtUser));
  }

  private static Set<UUID> parseRequestedGroupIds(Map<String, Object> updates) {
    var requestedGroupIds = new LinkedHashSet<UUID>();

    if (updates.containsKey("groupIds")) {
      var rawGroupIds = updates.get("groupIds");

      if (rawGroupIds instanceof Collection<?> groupIds) {
        groupIds.stream()
            .filter(Objects::nonNull)
            .map(Object::toString)
            .filter(rawGroupId -> !rawGroupId.isBlank())
            .map(UUID::fromString)
            .forEach(requestedGroupIds::add);
      } else if (rawGroupIds != null && !rawGroupIds.toString().isBlank()) {
        requestedGroupIds.add(UUID.fromString(rawGroupIds.toString()));
      }

      return requestedGroupIds;
    }

    var rawGroupId = updates.get("groupId");

    if (rawGroupId != null && !rawGroupId.toString().isBlank()) {
      requestedGroupIds.add(UUID.fromString(rawGroupId.toString()));
    }

    return requestedGroupIds;
  }

  @Override
  @Transactional(readOnly = true)
  public @NonNull Map<UUID, StudentWithStatusesResponse> getStudentsWithStatusesByIds(
      @NonNull List<UUID> studentIds, @NonNull JwtUser jwtUser) {
    return getStudentsWithStatuses(studentIds, null, jwtUser);
  }

  @Override
  @Transactional(readOnly = true)
  public @NonNull Map<UUID, StudentWithStatusesResponse> getStudentsWithStatusesByGroupId(
      @NonNull List<UUID> studentIds, @NonNull UUID groupId, @NonNull JwtUser jwtUser) {
    return getStudentsWithStatuses(studentIds, groupId, jwtUser);
  }

  private @NonNull Map<UUID, StudentWithStatusesResponse> getStudentsWithStatuses(
      @NonNull List<UUID> studentIds, UUID groupId, @NonNull JwtUser jwtUser) {
    log.info(
        "Getting students with statuses: studentIds={}; groupId={}; user={}",
        studentIds,
        groupId,
        jwtUser);

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

    var lessonsFuture =
        visitsFuture.thenComposeAsync(
            visits -> {
              var lessonIds =
                  visits.values().stream()
                      .flatMap(List::stream)
                      .map(VisitResponse::getLessonId)
                      .distinct()
                      .toList();

              if (lessonIds.isEmpty()) {
                return CompletableFuture.completedFuture(Map.<UUID, LessonResponse>of());
              }
              return CompletableFuture.supplyAsync(
                  () -> lessonSpi.getLessonsByIds(lessonIds, jwtUser), executor);
            },
            executor);

    AsyncUtils.awaitAll(visitsFuture, paymentsFuture, lessonsFuture);

    var visitsMap = visitsFuture.join();
    var paymentsMap = paymentsFuture.join();
    var lessonsMap = lessonsFuture.join();

    return studentsMap.values().stream()
        .collect(
            Collectors.toMap(
                StudentResponse::getId,
                student -> {
                  var studentVisits = visitsMap.getOrDefault(student.getId(), List.of());
                  var studentPayments = paymentsMap.getOrDefault(student.getId(), List.of());
                  var studentLessons =
                      studentVisits.stream()
                          .map(VisitResponse::getLessonId)
                          .distinct()
                          .map(lessonsMap::get)
                          .filter(Objects::nonNull)
                          .toList();

                  var visitLessons =
                      groupId == null
                          ? studentLessons
                          : studentLessons.stream()
                              .filter(lesson -> groupId.equals(lesson.getGroupId()))
                              .toList();

                  var statuses =
                      studentStatusService.getStudentStatuses(
                          studentVisits,
                          studentPayments,
                          studentLessons,
                          student.getFree(),
                          visitLessons);

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
