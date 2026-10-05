package org.trenero.backend.group.internal.service;

import static org.trenero.backend.common.exception.ExceptionUtils.entityNotFoundSupplier;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.UUID;
import java.util.function.Function;
import java.util.stream.Collectors;
import lombok.NonNull;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Lazy;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.trenero.backend.common.security.JwtUser;
import org.trenero.backend.group.external.GroupSpi;
import org.trenero.backend.group.external.response.GroupResponse;
import org.trenero.backend.group.external.response.GroupStudentResponse;
import org.trenero.backend.group.internal.domain.Group;
import org.trenero.backend.group.internal.mapper.GroupMapper;
import org.trenero.backend.group.internal.repository.GroupRepository;
import org.trenero.backend.group.internal.request.CreateGroupRequest;
import org.trenero.backend.group.internal.response.GroupStudentSummaryResponse;
import org.trenero.backend.group.internal.response.GroupSummaryResponse;
import org.trenero.backend.lesson.external.LessonSpi;
import org.trenero.backend.lesson.external.response.LessonResponse;
import org.trenero.backend.student.external.StudentSpi;
import org.trenero.backend.student.external.response.StudentWithStatusesResponse;

@Service
@Slf4j
@RequiredArgsConstructor
public class GroupService implements GroupSpi {

  private final GroupRepository groupRepository;
  private final GroupMapper groupMapper;

  @Lazy private final GroupStudentService groupStudentService;
  @Lazy private final LessonSpi lessonSpi;
  @Lazy private final StudentSpi studentSpi;
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
    return groupRepository
        .findByIdAndOwnerId(groupId, jwtUser.id())
        .map(group -> groupMapper.updateGroup(group, updates))
        .map(self::saveGroup)
        .map(groupMapper::toResponse)
        .orElseThrow(entityNotFoundSupplier(Group.class, groupId, jwtUser));
  }

  @Transactional
  public void deleteGroup(@NonNull UUID groupId, @NonNull JwtUser jwtUser) {
    log.info("Deleting group: groupId={}; user={}", groupId, jwtUser);

    groupStudentService.removeAllStudentsFromGroup(groupId, jwtUser);

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
