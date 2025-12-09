package tech.trenero.backend.group.internal.service;

import jakarta.persistence.EntityNotFoundException;
import java.util.List;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import tech.trenero.backend.common.response.GroupResponse;
import tech.trenero.backend.common.response.StudentResponse;
import tech.trenero.backend.common.security.JwtUser;
import tech.trenero.backend.group.internal.client.StudentClient;
import tech.trenero.backend.group.internal.entity.Group;
import tech.trenero.backend.group.internal.mapper.GroupMapper;
import tech.trenero.backend.group.internal.repository.GroupRepository;
import tech.trenero.backend.group.internal.request.GroupRequest;
import tech.trenero.backend.group.internal.response.GroupWithStudentsResponse;

@Service
@Slf4j
@RequiredArgsConstructor
public class GroupService {
  private final GroupRepository groupRepository;
  private final GroupMapper groupMapper;
  private final StudentClient studentClient;

  public List<GroupResponse> getAllGroupsForUser(JwtUser jwtUser) {
    log.info("Getting all groups for ownerId={}", jwtUser.userId());
    return groupRepository.findByOwnerId(jwtUser.userId()).stream()
        .map(groupMapper::toGroupResponse)
        .toList();
  }

  public GroupResponse getGroupForUserById(UUID groupId, JwtUser jwtUser) {
    log.info("Getting group for ownerId={}", jwtUser.userId());
    return groupRepository
        .findByIdAndOwnerId(groupId, jwtUser.userId())
        .map(groupMapper::toGroupResponse)
        .orElseThrow(
            () ->
                new EntityNotFoundException(
                    "Group not found with id=" + groupId + " and userId=" + jwtUser.userId()));
  }

  public GroupWithStudentsResponse getGroupWithStudentsForUserById(UUID groupId, JwtUser jwtUser) {
    log.info("Getting group with students by id={} for ownerId={}", groupId, jwtUser.userId());

    GroupResponse groupResponse =
        groupRepository
            .findByIdAndOwnerId(groupId, jwtUser.userId())
            .map(groupMapper::toGroupResponse)
            .orElseThrow(
                () ->
                    new EntityNotFoundException(
                        "Group not found with id=" + groupId + " and userId=" + jwtUser.userId()));

    List<StudentResponse> studentsByGroupId = studentClient.getStudentsByGroupId(groupId, jwtUser);

    return new GroupWithStudentsResponse(groupResponse, studentsByGroupId);
  }

  public List<GroupResponse> getGroupsByIdsAndOwner(List<UUID> groupIds, JwtUser jwtUser) {
    log.info("Getting groups by ids={} for ownerId={}", groupIds, jwtUser.userId());
    return groupRepository.findAllByIdAndOwnerId(groupIds, jwtUser.userId()).stream()
        .map(groupMapper::toGroupResponse)
        .toList();
  }

  public UUID createGroupForUser(GroupRequest groupRequest, JwtUser jwtUser) {
    log.info("Creating group: name='{}', ownerId={}", groupRequest.name(), jwtUser.userId());
    Group group = groupMapper.toGroup(groupRequest);
    group.setOwnerId(jwtUser.userId());
    return saveGroup(group);
  }

  public UUID saveGroup(Group group) {
    log.info("Saving group: {}", group);
    Group savedGroup = groupRepository.save(group);
    return savedGroup.getId();
  }
}
