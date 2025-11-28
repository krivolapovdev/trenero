package tech.trenero.backend.group.service;

import jakarta.persistence.EntityNotFoundException;
import java.util.List;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import tech.trenero.backend.common.response.GroupResponse;
import tech.trenero.backend.common.response.StudentResponse;
import tech.trenero.backend.group.client.StudentClient;
import tech.trenero.backend.group.entity.Group;
import tech.trenero.backend.group.mapper.GroupMapper;
import tech.trenero.backend.group.repository.GroupRepository;
import tech.trenero.backend.group.request.GroupRequest;
import tech.trenero.backend.group.response.GroupWithStudentsResponse;

@Service
@Slf4j
@RequiredArgsConstructor
public class GroupService {
  private final GroupRepository groupRepository;
  private final GroupMapper groupMapper;
  private final StudentClient studentClient;

  public List<GroupResponse> getAllGroups() {
    log.info("Getting all groups");
    return groupRepository.findAll().stream().map(groupMapper::toGroupResponse).toList();
  }

  public GroupWithStudentsResponse getGroupById(UUID id) {
    log.info("Getting group by id: {}", id);

    GroupResponse groupResponse =
        groupRepository
            .findById(id)
            .map(groupMapper::toGroupResponse)
            .orElseThrow(() -> new EntityNotFoundException("Group not found with id: " + id));

    List<StudentResponse> studentsByGroupId = studentClient.getStudentsByGroupId(id);

    return new GroupWithStudentsResponse(groupResponse, studentsByGroupId);
  }

  public List<GroupResponse> getGroupsByIds(List<UUID> groupIds) {
    log.info("Getting groups by ids: {}", groupIds);
    return groupRepository.findAllById(groupIds).stream()
        .map(groupMapper::toGroupResponse)
        .toList();
  }

  public UUID createGroup(GroupRequest groupRequest) {
    log.info("Creating group: {}", groupRequest);
    Group group = groupMapper.toGroup(groupRequest);
    return saveGroup(group);
  }

  public UUID saveGroup(Group group) {
    log.info("Saving group: {}", group);
    Group savedGroup = groupRepository.save(group);
    return savedGroup.getId();
  }
}
