package org.trenero.backend.group.internal.service;

import static org.trenero.backend.common.exception.ExceptionUtils.entityNotFoundSupplier;

import java.time.OffsetDateTime;
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
import org.trenero.backend.group.internal.domain.Group;
import org.trenero.backend.group.internal.mapper.GroupMapper;
import org.trenero.backend.group.internal.repository.GroupRepository;
import org.trenero.backend.group.internal.request.CreateGroupRequest;
import org.trenero.backend.group.internal.response.GroupDetailsResponse;
import org.trenero.backend.group.internal.response.GroupOverviewResponse;
import org.trenero.backend.lesson.external.LessonSpi;
import org.trenero.backend.student.external.StudentSpi;

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

  private final Executor executor;

  @Transactional(readOnly = true)
  public @NonNull List<GroupResponse> getAllGroups(@NonNull JwtUser jwtUser) {
    log.info("Getting all groups: user={}", jwtUser);
    return groupRepository.findAllByOwnerId(jwtUser.id()).stream()
        .map(groupMapper::toResponse)
        .toList();
  }

  @Transactional(readOnly = true)
  public @NonNull List<GroupOverviewResponse> getGroupsOverview(@NonNull JwtUser jwtUser) {
    log.info("Getting all groups overview: user={}", jwtUser);

    List<GroupResponse> allGroups = getAllGroups(jwtUser);

    if (allGroups.isEmpty()) {
      return List.of();
    }

    List<UUID> groupIds = allGroups.stream().map(GroupResponse::id).toList();

    Map<UUID, List<GroupStudentResponse>> groupStudents =
        groupStudentService.getStudentsByGroupIds(groupIds, jwtUser);

    return getAllGroups(jwtUser).stream()
        .map(
            group ->
                groupMapper.toGroupOverviewResponse(
                    group, groupStudents.getOrDefault(group.id(), List.of())))
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
  public @NonNull GroupDetailsResponse getGroupDetailsById(
      @NonNull UUID groupId, @NonNull JwtUser jwtUser) {
    log.info("Fetching parallel group details for groupId={} and userId={}", groupId, jwtUser.id());

    // 1. Launch independent queries in parallel threads
    var groupFuture =
        CompletableFuture.supplyAsync(() -> this.getGroupById(groupId, jwtUser), executor);

    var lessonsFuture =
        CompletableFuture.supplyAsync(
            () -> lessonSpi.getLessonsByGroupId(groupId, jwtUser), executor);

    // 2. Chain the student fetching (dependent on the group-student linking table)
    var groupStudentsFuture =
        CompletableFuture.supplyAsync(
                () -> groupStudentService.getStudentsByGroupId(groupId, jwtUser), executor)
            .thenComposeAsync(
                studentLinks -> {
                  List<UUID> studentIds =
                      studentLinks.stream().map(GroupStudentResponse::studentId).toList();

                  // Short-circuit to prevent SQL IN() syntax errors if the group is empty
                  if (studentIds.isEmpty()) {
                    return CompletableFuture.completedFuture(List.<StudentResponse>of());
                  }

                  return CompletableFuture.supplyAsync(
                      () ->
                          studentSpi.getStudentsByIds(studentIds, jwtUser).values().stream()
                              .flatMap(List::stream)
                              .toList(),
                      executor);
                },
                executor);

    // 3. Await all background tasks simultaneously
    AsyncUtils.awaitAll(groupFuture, lessonsFuture, groupStudentsFuture);

    // 4. Extract values
    GroupResponse group = groupFuture.join();
    List<LessonResponse> groupLessons = lessonsFuture.join();
    List<StudentResponse> groupStudents = groupStudentsFuture.join();

    return groupMapper.toGroupDetailsResponse(group, groupStudents, groupLessons);
  }

  @Override
  public @NonNull Map<UUID, GroupResponse> getGroupsByIds(
      @NonNull List<UUID> groupIds, @NonNull JwtUser jwtUser) {
    log.info("Getting groups by ids: groupIds={}; user={}", groupIds, jwtUser);

    return groupRepository.findAllByIdsAndOwnerId(groupIds, jwtUser.id()).stream()
        .map(groupMapper::toResponse)
        .collect(Collectors.toMap(GroupResponse::id, Function.identity()));
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
  public void softDeleteGroup(@NonNull UUID groupId, @NonNull JwtUser jwtUser) {
    log.info("Deleting group: groupId={}; user={}", groupId, jwtUser);

    groupStudentService.removeAllStudentsFromGroup(groupId, jwtUser);

    groupRepository
        .findByIdAndOwnerId(groupId, jwtUser.id())
        .map(
            group -> {
              group.setDeletedAt(OffsetDateTime.now());
              return self.saveGroup(group);
            })
        .orElseThrow(entityNotFoundSupplier(Group.class, groupId, jwtUser));
  }

  @Transactional
  public @NonNull Group saveGroup(@NonNull Group group) {
    log.info("Saving group: group={}", group);
    return groupRepository.saveAndFlush(group);
  }
}
