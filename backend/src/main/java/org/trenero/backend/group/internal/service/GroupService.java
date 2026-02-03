package org.trenero.backend.group.internal.service;

import jakarta.persistence.EntityNotFoundException;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.function.Function;
import java.util.stream.Collectors;
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
  @Lazy private final GroupRepository groupRepository;
  @Lazy private final GroupMapper groupMapper;
  @Lazy private final GroupService self;
  @Lazy private final GroupStudentService groupStudentService;
  @Lazy private final LessonSpi lessonSpi;
  @Lazy private final StudentSpi studentSpi;

  @Transactional(readOnly = true)
  public List<GroupResponse> getAllGroups(JwtUser jwtUser) {
    log.info("Getting all groups for ownerId={}", jwtUser.userId());
    return groupRepository.findAllByOwnerId(jwtUser.userId()).stream()
        .map(groupMapper::toResponse)
        .toList();
  }

  @Transactional(readOnly = true)
  public List<GroupOverviewResponse> getGroupsOverview(JwtUser jwtUser) {
    log.info("Getting groups overview for ownerId={}", jwtUser.userId());

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
  public GroupResponse getGroupById(UUID groupId, JwtUser jwtUser) {
    log.info("Getting group by id={} for ownerId={}", groupId, jwtUser.userId());
    return groupRepository
        .findByIdAndOwnerId(groupId, jwtUser.userId())
        .map(groupMapper::toResponse)
        .orElseThrow(() -> new EntityNotFoundException("Group not found: " + groupId));
  }

  @Transactional(readOnly = true)
  public GroupDetailsResponse getGroupDetailsById(UUID groupId, JwtUser jwtUser) {
    log.info("Getting group details by id={} for ownerId={}", groupId, jwtUser.userId());

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
  public Map<UUID, GroupResponse> getGroupsByIds(List<UUID> groupIds, JwtUser jwtUser) {
    log.info("Getting groups by ids for ownerId={}", jwtUser.userId());

    return groupRepository.findAllByIdsAndOwnerId(groupIds, jwtUser.userId()).stream()
        .map(groupMapper::toResponse)
        .collect(Collectors.toMap(GroupResponse::id, Function.identity()));
  }

  @Transactional
  public GroupResponse createGroup(CreateGroupRequest request, JwtUser jwtUser) {
    log.info("Creating group: name='{}', ownerId={}", request.name(), jwtUser.userId());

    Group group = groupMapper.toGroup(request, jwtUser.userId());
    Group savedGroup = self.saveGroup(group);

    groupStudentService.addStudentsToGroup(savedGroup.getId(), request.studentIds(), jwtUser);

    return groupMapper.toResponse(savedGroup);
  }

  @Transactional
  public GroupResponse updateGroup(UUID groupId, Map<String, Object> updates, JwtUser jwtUser) {
    log.info("Updating group: groupId='{}', ownerId={}", groupId, jwtUser.userId());

    return groupRepository
        .findByIdAndOwnerId(groupId, jwtUser.userId())
        .map(group -> groupMapper.updateGroup(group, updates))
        .map(self::saveGroup)
        .map(groupMapper::toResponse)
        .orElseThrow(() -> new EntityNotFoundException("Group not found: " + groupId));
  }

  @Transactional
  public void softDeleteGroup(UUID groupId, JwtUser jwtUser) {
    log.info("Deleting group: {}", groupId);

    groupStudentService.removeAllStudentsFromGroup(groupId, jwtUser);

    groupRepository
        .findByIdAndOwnerId(groupId, jwtUser.userId())
        .map(
            group -> {
              group.setDeletedAt(OffsetDateTime.now());
              return self.saveGroup(group);
            })
        .orElseThrow(() -> new EntityNotFoundException("Group not found: " + groupId));
  }

  @Transactional
  public Group saveGroup(Group group) {
    log.info("Saving group: {}", group);
    return groupRepository.saveAndFlush(group);
  }
}
