package tech.trenero.backend.group.internal.service;

import jakarta.persistence.EntityNotFoundException;
import java.util.List;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Lazy;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import tech.trenero.backend.common.response.GroupResponse;
import tech.trenero.backend.common.response.StudentResponse;
import tech.trenero.backend.common.security.JwtUser;
import tech.trenero.backend.group.internal.entity.Group;
import tech.trenero.backend.group.internal.mapper.GroupMapper;
import tech.trenero.backend.group.internal.repository.GroupRepository;
import tech.trenero.backend.group.internal.request.AddStudentRequest;
import tech.trenero.backend.group.internal.request.CreateGroupRequest;
import tech.trenero.backend.group.internal.request.RemoveStudentRequest;
import tech.trenero.backend.group.internal.response.GroupWithStudentsResponse;
import tech.trenero.backend.student.external.StudentSpi;

@Service
@Slf4j
@RequiredArgsConstructor
public class GroupService {
  private final GroupRepository groupRepository;
  private final GroupMapper groupMapper;
  @Lazy private final StudentSpi studentSpi;

  public List<GroupResponse> getAllGroups(JwtUser jwtUser) {
    log.info("Getting all groups for ownerId={}", jwtUser.userId());
    return groupRepository.findAllByOwnerId(jwtUser.userId()).stream()
        .map(groupMapper::toGroupResponse)
        .toList();
  }

  public GroupResponse getGroupById(UUID groupId, JwtUser jwtUser) {
    log.info("Getting group by id={} for ownerId={}", groupId, jwtUser.userId());
    Group group = findGroupOrThrow(groupId, jwtUser);
    return groupMapper.toGroupResponse(group);
  }

  public GroupWithStudentsResponse getGroupWithStudentsById(UUID groupId, JwtUser jwtUser) {
    log.info("Getting group with students by id={} for ownerId={}", groupId, jwtUser.userId());
    Group group = findGroupOrThrow(groupId, jwtUser);
    List<StudentResponse> students = studentSpi.getStudentsByIds(group.getStudentIds(), jwtUser);
    return new GroupWithStudentsResponse(groupMapper.toGroupResponse(group), students);
  }

  public List<GroupResponse> getGroupsByStudentId(UUID studentId, JwtUser jwtUser) {
    log.info("Getting groups by studentId={} for ownerId={}", studentId, jwtUser.userId());
    return groupRepository
        .findAllByStudentIdsContainsAndOwnerId(studentId, jwtUser.userId())
        .stream()
        .map(groupMapper::toGroupResponse)
        .toList();
  }

  @Transactional
  public UUID createGroup(CreateGroupRequest createGroupRequest, JwtUser jwtUser) {
    log.info("Creating group: name='{}', ownerId={}", createGroupRequest.name(), jwtUser.userId());
    Group group = groupMapper.toGroup(createGroupRequest);
    group.setOwnerId(jwtUser.userId());
    return saveGroup(group);
  }

  @Transactional
  public UUID saveGroup(Group group) {
    log.info("Saving group: {}", group);
    Group savedGroup = groupRepository.save(group);
    return savedGroup.getId();
  }

  @Transactional
  public void addStudentToGroup(UUID groupId, AddStudentRequest request, JwtUser jwtUser) {
    log.info(
        "Adding student to group: groupId={}, studentId={}, ownerId={}",
        groupId,
        request.studentId(),
        jwtUser.userId());

    Group group = findGroupOrThrow(groupId, jwtUser);

    validateStudentById(request.studentId(), jwtUser);

    group.getStudentIds().add(request.studentId());

    saveGroup(group);
  }

  @Transactional
  public void assignGroupsToStudent(UUID studentId, List<UUID> studentGroups, JwtUser jwtUser) {
    log.info(
        "Assigning groups to student: studentId={}, groups={}, ownerId={}",
        studentId,
        studentGroups,
        jwtUser.userId());

    validateStudentById(studentId, jwtUser);

    List<Group> groups = groupRepository.findAllByIdInAndOwnerId(studentGroups, jwtUser.userId());

    groups.forEach(group -> group.getStudentIds().add(studentId));

    groupRepository.saveAll(groups);
  }

  @Transactional
  public void removeStudentFromGroup(UUID groupId, RemoveStudentRequest request, JwtUser jwtUser) {
    log.info(
        "Removing student from group: groupId={}, studentId={}, ownerId={}",
        groupId,
        request.studentId(),
        jwtUser.userId());

    Group group = findGroupOrThrow(groupId, jwtUser);

    group.getStudentIds().remove(request.studentId());

    saveGroup(group);
  }

  private Group findGroupOrThrow(UUID groupId, JwtUser jwtUser) {
    log.debug("Fetching group by id={} for ownerId={}", groupId, jwtUser.userId());
    return groupRepository
        .findByIdAndOwnerId(groupId, jwtUser.userId())
        .orElseThrow(
            () ->
                new EntityNotFoundException(
                    "Group not found with id=" + groupId + " and ownerId=" + jwtUser.userId()));
  }

  private void validateStudentById(UUID studentId, JwtUser jwtUser) {
    log.debug("Checking if student exists by id={} for user={}", studentId, jwtUser.userId());
    studentSpi.getStudentById(studentId, jwtUser);
  }
}
