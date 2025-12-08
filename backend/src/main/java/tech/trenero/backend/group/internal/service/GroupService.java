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

  public GroupWithStudentsResponse getUserGroupById(UUID groupId, JwtUser jwtUser) {
    log.info("Getting group by id={} for ownerId={}", groupId, jwtUser.userId());

    GroupResponse groupResponse =
        groupRepository
            .findByIdAndOwnerId(groupId, jwtUser.userId())
            .map(groupMapper::toGroupResponse)
            .orElseThrow(
                () ->
                    new EntityNotFoundException(
                        "Group not found with id: " + groupId + " for current user"));

    List<StudentResponse> studentsByGroupId = studentClient.getStudentsByGroupId(groupId);

    return new GroupWithStudentsResponse(groupResponse, studentsByGroupId);
  }

  public List<GroupResponse> getGroupsByIds(List<UUID> groupIds) {
    log.info("Getting groups by ids: {}", groupIds);
    return groupRepository.findAllById(groupIds).stream()
        .map(groupMapper::toGroupResponse)
        .toList();
  }

  public UUID createGroup(GroupRequest groupRequest, JwtUser jwtUser) {
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
