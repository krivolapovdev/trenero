package org.trenero.backend.group.internal.service;

import static org.trenero.backend.common.exception.ExceptionUtils.entityNotFoundSupplier;

import java.time.LocalDate;
import java.util.Collection;
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

    Map<UUID, StudentWithStatusesResponse> studentMap =
        studentSpi.getStudentsWithStatusesByIds(studentIds, jwtUser);

    return studentIds.stream()
        .map(studentMap::get)
        .filter(Objects::nonNull)
        .map(s -> new GroupStudentSummaryResponse(s.getStudent(), s.getStatuses()))
        .toList();
  }

  @Transactional(readOnly = true)
  public @NonNull List<LessonResponse> getGroupLessons(
      @NonNull UUID groupId,
      @NonNull LocalDate from,
      @NonNull LocalDate to,
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

    LocalDate from = LocalDate.of(year, month, 1);
    LocalDate to = from.withDayOfMonth(from.lengthOfMonth());

    List<UUID> studentIds =
        groupStudentService.getStudentsByGroupId(groupId, jwtUser).stream()
            .map(GroupStudentResponse::getStudentId)
            .distinct()
            .toList();

    if (studentIds.isEmpty()) {
      return groupReportService.buildReport(
          group, year, month, List.of(), List.of(), Map.of(), Map.of(), LocalDate.now());
    }

    Map<UUID, StudentResponse> studentsMap = studentSpi.getStudentsByIds(studentIds, jwtUser);
    List<StudentResponse> students =
        studentIds.stream().map(studentsMap::get).filter(Objects::nonNull).toList();

    List<LessonResponse> lessons =
        lessonSpi.getLessonsByGroupIdAndDateRange(groupId, from, to, jwtUser);
    Map<UUID, List<VisitResponse>> visitsByStudentId =
        visitSpi.getVisitsByStudentIds(studentIds, jwtUser);
    Map<UUID, List<TransactionResponse>> paymentsByStudentId =
        transactionSpi.getTransactionsByStudentIds(studentIds, jwtUser);

    return groupReportService.buildReport(
        group,
        year,
        month,
        students,
        lessons,
        visitsByStudentId,
        paymentsByStudentId,
        LocalDate.now());
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

    Group group = groupMapper.toGroup(request, jwtUser.id());
    Group savedGroup = self.saveGroup(group);

    groupStudentService.addStudentsToGroup(savedGroup.getId(), request.studentIds(), jwtUser);

    return groupMapper.toResponse(savedGroup);
  }

  @Transactional
  public @NonNull GroupResponse updateGroup(
      @NonNull UUID groupId, @NonNull Map<String, Object> updates, @NonNull JwtUser jwtUser) {
    log.info("Updating group: groupId={}; updates={}; user={}", groupId, updates, jwtUser);

    var group =
        groupRepository
            .findByIdAndOwnerId(groupId, jwtUser.id())
            .orElseThrow(entityNotFoundSupplier(Group.class, groupId, jwtUser));

    if (updates.containsKey("studentIds")) {
      reconcileGroupStudents(groupId, updates, jwtUser);
    }

    var updatedGroup = groupMapper.updateGroup(group, updates);
    var savedGroup = self.saveGroup(updatedGroup);

    return groupMapper.toResponse(savedGroup);
  }

  /**
   * Brings the student links of a group in line with the students the request picked: a student the
   * request left out is dropped from the group, a picked student the group did not hold yet is
   * added. An empty pick leaves the group without any student.
   */
  private void reconcileGroupStudents(UUID groupId, Map<String, Object> updates, JwtUser jwtUser) {
    var requestedStudentIds = parseRequestedStudentIds(updates);
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

  /**
   * The students the request wants the group to hold, sent by the group students page as {@code
   * studentIds}. A blank value leaves the group without any student.
   */
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
