package org.trenero.backend.group.internal.service;

import static org.trenero.backend.common.exception.ExceptionUtils.entityNotFoundSupplier;

import java.time.OffsetDateTime;
import java.util.List;
import java.util.Map;
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

  @Transactional(readOnly = true)
  public @NonNull List<GroupResponse> getAllGroups(@NonNull JwtUser jwtUser) {
    log.info("Getting all groups: user={}", jwtUser);
    return groupRepository.findAllByOwnerId(jwtUser.userId()).stream()
        .map(groupMapper::toResponse)
        .toList();
  }

  @Transactional(readOnly = true)
  public List<GroupOverviewResponse> getGroupsOverview(JwtUser jwtUser) {
    log.info("Getting all groups overview: user={}", jwtUser);

    List<GroupResponse> allGroups = self.getAllGroups(jwtUser);
    List<UUID> groupIds = allGroups.stream().map(GroupResponse::id).toList();

    Map<UUID, List<GroupStudentResponse>> groupStudents =
        groupStudentService.getStudentsByGroupIds(groupIds, jwtUser);

    return allGroups.stream()
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
        .findByIdAndOwnerId(groupId, jwtUser.userId())
        .map(groupMapper::toResponse)
        .orElseThrow(entityNotFoundSupplier(Group.class, groupId, jwtUser));
  }

  @Transactional(readOnly = true)
  public GroupDetailsResponse getGroupDetailsById(UUID groupId, JwtUser jwtUser) {
    log.info("Getting group details by id: groupId={}; user={}", groupId, jwtUser);

    List<UUID> studentIds =
        groupStudentService.getStudentsByGroupId(groupId, jwtUser).stream()
            .map(GroupStudentResponse::studentId)
            .toList();

    Map<UUID, List<StudentResponse>> studentsMap = studentSpi.getStudentsByIds(studentIds, jwtUser);

    List<StudentResponse> groupStudents =
        studentsMap.values().stream().flatMap(List::stream).toList();

    GroupResponse group = self.getGroupById(groupId, jwtUser);
    List<LessonResponse> groupLessons = lessonSpi.getLessonsByGroupId(groupId, jwtUser);

    return groupMapper.toGroupDetailsResponse(group, groupStudents, groupLessons);
  }

  @Override
  public @NonNull Map<UUID, GroupResponse> getGroupsByIds(
      @NonNull List<UUID> groupIds, @NonNull JwtUser jwtUser) {
    log.info("Getting groups by ids: groupIds={}; user={}", groupIds, jwtUser);

    return groupRepository.findAllByIdsAndOwnerId(groupIds, jwtUser.userId()).stream()
        .map(groupMapper::toResponse)
        .collect(Collectors.toMap(GroupResponse::id, Function.identity()));
  }

  @Transactional
  public GroupResponse createGroup(CreateGroupRequest request, JwtUser jwtUser) {
    log.info("Creating group: request={}; user={}", request, jwtUser);

    Group group = groupMapper.toGroup(request, jwtUser.userId());
    Group savedGroup = self.saveGroup(group);

    groupStudentService.addStudentsToGroup(savedGroup.getId(), request.studentIds(), jwtUser);

    return groupMapper.toResponse(savedGroup);
  }

  @Transactional
  public GroupResponse updateGroup(UUID groupId, Map<String, Object> updates, JwtUser jwtUser) {
    log.info("Updating group: groupId={}; updates={}; user={}", groupId, updates, jwtUser);
    return groupRepository
        .findByIdAndOwnerId(groupId, jwtUser.userId())
        .map(group -> groupMapper.updateGroup(group, updates))
        .map(self::saveGroup)
        .map(groupMapper::toResponse)
        .orElseThrow(entityNotFoundSupplier(Group.class, groupId, jwtUser));
  }

  @Transactional
  public void softDeleteGroup(UUID groupId, JwtUser jwtUser) {
    log.info("Deleting group: groupId={}; user={}", groupId, jwtUser);

    groupStudentService.removeAllStudentsFromGroup(groupId, jwtUser);

    groupRepository
        .findByIdAndOwnerId(groupId, jwtUser.userId())
        .map(
            group -> {
              group.setDeletedAt(OffsetDateTime.now());
              return self.saveGroup(group);
            })
        .orElseThrow(entityNotFoundSupplier(Group.class, groupId, jwtUser));
  }

  @Transactional
  public Group saveGroup(Group group) {
    log.info("Saving group: group={}", group);
    return groupRepository.saveAndFlush(group);
  }
}
