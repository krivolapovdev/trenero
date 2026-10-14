package org.trenero.backend.group.internal.service;

import static org.trenero.backend.common.exception.ExceptionUtils.entityNotFoundSupplier;

import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.time.temporal.TemporalAdjusters;
import java.util.Collection;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.UUID;
import java.util.function.Function;
import java.util.stream.Collectors;
import lombok.NonNull;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Lazy;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;
import org.trenero.backend.common.exception.ApiErrorCode;
import org.trenero.backend.common.exception.ConflictException;
import org.trenero.backend.common.security.JwtUser;
import org.trenero.backend.group.external.response.GroupResponse;
import org.trenero.backend.group.external.response.GroupStudentResponse;
import org.trenero.backend.group.external.spi.GroupSpi;
import org.trenero.backend.group.internal.domain.Group;
import org.trenero.backend.group.internal.mapper.GroupMapper;
import org.trenero.backend.group.internal.repository.GroupRepository;
import org.trenero.backend.group.internal.request.CreateGroupRequest;
import org.trenero.backend.group.internal.response.GroupReportResponse;
import org.trenero.backend.group.internal.response.GroupStudentSummaryResponse;
import org.trenero.backend.group.internal.response.GroupSummaryResponse;
import org.trenero.backend.lesson.external.response.LessonResponse;
import org.trenero.backend.lesson.external.spi.LessonSpi;
import org.trenero.backend.student.external.response.StudentResponse;
import org.trenero.backend.student.external.response.StudentWithStatusesResponse;
import org.trenero.backend.student.external.spi.StudentSpi;
import org.trenero.backend.transaction.external.response.TransactionResponse;
import org.trenero.backend.transaction.external.spi.TransactionSpi;
import org.trenero.backend.visit.external.response.VisitResponse;
import org.trenero.backend.visit.external.spi.VisitSpi;

@Service
@Slf4j
@RequiredArgsConstructor
public class GroupService implements GroupSpi {

  private final GroupRepository groupRepository;
  private final GroupMapper groupMapper;
  private final GroupReportService groupReportService;

  @Lazy private final GroupStudentService groupStudentService;
  @Lazy private final LessonSpi lessonSpi;
  @Lazy private final StudentSpi studentSpi;
  @Lazy private final VisitSpi visitSpi;
  @Lazy private final TransactionSpi transactionSpi;
  @Lazy private final GroupService self;

  @Transactional(readOnly = true)
  public @NonNull List<GroupSummaryResponse> getAllGroupsSummary(@NonNull JwtUser jwtUser) {
    log.info("Getting all groups summary: user={}", jwtUser);
    List<Group> allGroups = groupRepository.findAllByOwnerId(jwtUser.id());

    if (allGroups.isEmpty()) {
      return List.of();
    }

    List<UUID> groupIds = allGroups.stream().map(Group::getId).toList();

    Map<UUID, Long> studentCountsMap =
        groupStudentService.getStudentCountsByGroupIds(groupIds, jwtUser);

    return allGroups.stream()
        .map(
            group -> {
              long countOfStudents = studentCountsMap.getOrDefault(group.getId(), 0L);
              GroupResponse groupResponse = groupMapper.toResponse(group);
              return new GroupSummaryResponse(groupResponse, countOfStudents);
            })
        .toList();
  }

  @Transactional(readOnly = true)
  public @NonNull GroupResponse getGroupById(@NonNull UUID groupId, @NonNull JwtUser jwtUser) {
    log.info("Getting group by id: groupId={}; user={}", groupId, jwtUser);
    return groupRepository
        .findByIdAndOwnerId(groupId, jwtUser.id())
        .map(groupMapper::toResponse)
        .orElseThrow(entityNotFoundSupplier(Group.class, groupId, jwtUser));
  }

  @Transactional(readOnly = true)
  public @NonNull List<GroupStudentSummaryResponse> getGroupStudents(
      @NonNull UUID groupId, @NonNull JwtUser jwtUser) {
    log.info("Getting students for group: groupId={}; user={}", groupId, jwtUser);

    getGroupById(groupId, jwtUser);

    List<GroupStudentResponse> studentLinks =
        groupStudentService.getStudentsByGroupId(groupId, jwtUser);

    if (studentLinks.isEmpty()) {
      return List.of();
    }

    List<UUID> studentIds =
        studentLinks.stream().map(GroupStudentResponse::getStudentId).distinct().toList();

    // The students are shown on the group page, so their visit badge is read from the lessons of
    // this group instead of the lessons of every group they belong to.
    Map<UUID, StudentWithStatusesResponse> studentMap =
        studentSpi.getStudentsWithStatusesByGroupId(studentIds, groupId, jwtUser);

    return studentIds.stream()
        .map(studentMap::get)
        .filter(Objects::nonNull)
        .map(s -> new GroupStudentSummaryResponse(s.getStudent(), s.getStatuses()))
        .toList();
  }

  @Transactional(readOnly = true)
  public @NonNull List<LessonResponse> getGroupLessons(
      @NonNull UUID groupId,
      @NonNull OffsetDateTime from,
      @NonNull OffsetDateTime to,
      @NonNull JwtUser jwtUser) {
    log.info(
        "Getting lessons for group by date range: groupId={}; from={}; to={}; user={}",
        groupId,
        from,
        to,
        jwtUser);

    getGroupById(groupId, jwtUser);

    return lessonSpi.getLessonsByGroupIdAndDateRange(groupId, from, to, jwtUser);
  }

  @Transactional(readOnly = true)
  public @NonNull GroupReportResponse getGroupReport(
      @NonNull UUID groupId, int year, int month, @NonNull JwtUser jwtUser) {
    log.info(
        "Getting group report: groupId={}; year={}; month={}; user={}",
        groupId,
        year,
        month,
        jwtUser);

    validateReportPeriod(year, month);

    GroupResponse group = getGroupById(groupId, jwtUser);

    OffsetDateTime monthStart = OffsetDateTime.of(year, month, 1, 0, 0, 0, 0, ZoneOffset.UTC);
    OffsetDateTime from = monthStart.minusDays(1);
    OffsetDateTime to = monthStart.with(TemporalAdjusters.lastDayOfMonth()).plusDays(1);

    List<LessonResponse> lessons =
        lessonSpi.getLessonsByGroupIdAndDateRange(groupId, from, to, jwtUser);
    List<UUID> lessonIds = lessons.stream().map(LessonResponse::getId).distinct().toList();

    // The rows of the report are driven by the visits of the reported lessons, because leaving a
    // group deletes the student link: a student that came to a lesson of the month has to keep
    // showing up after they left the group. The students still linked to the group are added as
    // well, so they are listed with an empty result when the month holds no visit for them.
    List<VisitResponse> lessonVisits =
        lessonIds.isEmpty() ? List.of() : visitSpi.getVisitsByLessonIds(lessonIds, jwtUser);

    Set<UUID> studentIds = new LinkedHashSet<>();
    groupStudentService.getStudentsByGroupId(groupId, jwtUser).stream()
        .map(GroupStudentResponse::getStudentId)
        .forEach(studentIds::add);
    lessonVisits.stream().map(VisitResponse::getStudentId).forEach(studentIds::add);

    if (studentIds.isEmpty()) {
      return groupReportService.buildReport(
          group, year, month, List.of(), lessons, Map.of(), Map.of(), OffsetDateTime.now());
    }

    List<UUID> distinctStudentIds = List.copyOf(studentIds);

    Map<UUID, StudentResponse> studentsMap =
        studentSpi.getStudentsByIds(distinctStudentIds, jwtUser);
    List<StudentResponse> students =
        distinctStudentIds.stream().map(studentsMap::get).filter(Objects::nonNull).toList();

    Map<UUID, List<VisitResponse>> visitsByStudentId =
        lessonVisits.stream().collect(Collectors.groupingBy(VisitResponse::getStudentId));
    Map<UUID, List<TransactionResponse>> paymentsByStudentId =
        transactionSpi.getTransactionsByStudentIds(distinctStudentIds, jwtUser);

    return groupReportService.buildReport(
        group,
        year,
        month,
        students,
        lessons,
        visitsByStudentId,
        paymentsByStudentId,
        OffsetDateTime.now());
  }

  private static void validateReportPeriod(int year, int month) {
    if (month < 1 || month > 12) {
      throw new ResponseStatusException(
          HttpStatus.BAD_REQUEST, "month must be in range 1..12, but was " + month);
    }

    if (year < 1 || year > 9999) {
      throw new ResponseStatusException(
          HttpStatus.BAD_REQUEST, "year must be in range 1..9999, but was " + year);
    }
  }

  @Override
  public @NonNull Map<UUID, GroupResponse> getGroupsByIds(
      @NonNull List<UUID> groupIds, @NonNull JwtUser jwtUser) {
    log.info("Getting groups by ids: groupIds={}; user={}", groupIds, jwtUser);

    return groupRepository.findAllByIdsAndOwnerId(groupIds, jwtUser.id()).stream()
        .map(groupMapper::toResponse)
        .collect(Collectors.toMap(GroupResponse::getId, Function.identity()));
  }

  @Transactional
  public @NonNull GroupResponse createGroup(
      @NonNull CreateGroupRequest request, @NonNull JwtUser jwtUser) {
    log.info("Creating group: request={}; user={}", request, jwtUser);

    String name = requireTrimmedName(request.name());
    requireFreeName(name, null, jwtUser);

    List<UUID> studentIds =
        request.studentIds().stream().filter(Objects::nonNull).distinct().toList();
    requireExistingStudents(studentIds, jwtUser);

    Group group = groupMapper.toGroup(request, jwtUser.id());
    // The mapper copies the name as it was sent; the row keeps the trimmed one.
    group.setName(name);
    Group savedGroup = self.saveGroup(group);

    groupStudentService.addStudentsToGroup(savedGroup.getId(), studentIds, jwtUser);

    return groupMapper.toResponse(savedGroup);
  }

  /**
   * The name of a group is the only handle it has on every page, so a write that carries a name has
   * to carry a usable one. The value is trimmed, so that two names that differ in nothing but
   * surrounding blanks are recognized as the same name by {@link #requireFreeName}.
   */
  private static @NonNull String requireTrimmedName(Object name) {
    if (!(name instanceof String text) || text.isBlank()) {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "name must not be blank");
    }

    String trimmed = text.trim();
    if (trimmed.length() > 255) {
      throw new ResponseStatusException(
          HttpStatus.BAD_REQUEST, "name must not exceed 255 characters");
    }
    return trimmed;
  }

  /**
   * Only the students of the caller belong into a group. Nothing references `students(id)`, so a
   * link to a student that does not exist is accepted by the schema - and then counted by {@link
   * #getAllGroupsSummary} while the group page can never show it.
   */
  private void requireExistingStudents(Collection<UUID> studentIds, JwtUser jwtUser) {
    if (studentIds.isEmpty()) {
      return;
    }

    Map<UUID, StudentResponse> existingStudents =
        studentSpi.getStudentsByIds(List.copyOf(studentIds), jwtUser);
    List<UUID> unknownStudentIds =
        studentIds.stream().filter(studentId -> !existingStudents.containsKey(studentId)).toList();

    if (!unknownStudentIds.isEmpty()) {
      throw new ResponseStatusException(
          HttpStatus.BAD_REQUEST, "unknown students: " + unknownStudentIds);
    }
  }

  private void requireFreeName(String name, UUID groupId, JwtUser jwtUser) {
    boolean taken =
        groupId == null
            ? groupRepository.existsByOwnerIdAndName(jwtUser.id(), name)
            : groupRepository.existsByOwnerIdAndNameAndIdNot(jwtUser.id(), name, groupId);

    if (taken) {
      throw new ConflictException(
          ApiErrorCode.GROUP_NAME_NOT_UNIQUE,
          "A group named \"%s\" already exists".formatted(name));
    }
  }

  @Transactional
  public @NonNull GroupResponse updateGroup(
      @NonNull UUID groupId, @NonNull Map<String, Object> updates, @NonNull JwtUser jwtUser) {
    log.info("Updating group: groupId={}; updates={}; user={}", groupId, updates, jwtUser);

    var group =
        groupRepository
            .findByIdAndOwnerId(groupId, jwtUser.id())
            .orElseThrow(entityNotFoundSupplier(Group.class, groupId, jwtUser));

    Map<String, Object> patch = new LinkedHashMap<>(updates);

    if (patch.containsKey("name")) {
      String name = requireTrimmedName(patch.get("name"));
      requireFreeName(name, groupId, jwtUser);
      patch.put("name", name);
    }

    if (patch.containsKey("studentIds")) {
      var requestedStudentIds = parseRequestedStudentIds(patch);
      requireExistingStudents(requestedStudentIds, jwtUser);
      reconcileGroupStudents(groupId, requestedStudentIds, jwtUser);
    }

    var updatedGroup = groupMapper.updateGroup(group, patch);
    var savedGroup = self.saveGroup(updatedGroup);

    return groupMapper.toResponse(savedGroup);
  }

  private void reconcileGroupStudents(
      UUID groupId, Set<UUID> requestedStudentIds, JwtUser jwtUser) {
    var currentStudentIds =
        groupStudentService.getStudentsByGroupId(groupId, jwtUser).stream()
            .map(GroupStudentResponse::getStudentId)
            .collect(Collectors.toSet());

    currentStudentIds.stream()
        .filter(studentId -> !requestedStudentIds.contains(studentId))
        .forEach(
            studentId -> groupStudentService.removeStudentFromGroup(studentId, groupId, jwtUser));

    var studentIdsToAdd =
        requestedStudentIds.stream().filter(id -> !currentStudentIds.contains(id)).toList();

    if (!studentIdsToAdd.isEmpty()) {
      groupStudentService.addStudentsToGroup(groupId, studentIdsToAdd, jwtUser);
    }
  }

  private static Set<UUID> parseRequestedStudentIds(Map<String, Object> updates) {
    var rawStudentIds = updates.get("studentIds");
    var requestedStudentIds = new LinkedHashSet<UUID>();

    if (rawStudentIds instanceof Collection<?> studentIds) {
      studentIds.stream()
          .filter(Objects::nonNull)
          .map(Object::toString)
          .filter(rawStudentId -> !rawStudentId.isBlank())
          .map(UUID::fromString)
          .forEach(requestedStudentIds::add);
    } else if (rawStudentIds != null && !rawStudentIds.toString().isBlank()) {
      requestedStudentIds.add(UUID.fromString(rawStudentIds.toString()));
    }

    return requestedStudentIds;
  }

  @Transactional
  public void deleteGroup(@NonNull UUID groupId, @NonNull JwtUser jwtUser) {
    log.info("Deleting group: groupId={}; user={}", groupId, jwtUser);

    Group group =
        groupRepository
            .findByIdAndOwnerId(groupId, jwtUser.id())
            .orElseThrow(entityNotFoundSupplier(Group.class, groupId, jwtUser));

    groupRepository.delete(group);
  }

  @Transactional
  public @NonNull Group saveGroup(@NonNull Group group) {
    log.info("Saving group: group={}", group);
    return groupRepository.saveAndFlush(group);
  }
}
