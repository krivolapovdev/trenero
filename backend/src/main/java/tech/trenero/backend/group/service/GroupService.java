package tech.trenero.backend.group.service;

import java.util.List;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import tech.trenero.backend.group.entity.Group;
import tech.trenero.backend.group.repository.GroupRepository;
import tech.trenero.backend.group.request.GroupRequest;

@Service
@Slf4j
@RequiredArgsConstructor
public class GroupService {
  private final GroupRepository groupRepository;

  public List<Group> getAllGroups() {
    log.info("Getting all groups");
    return groupRepository.findAll();
  }

  public UUID createGroup(GroupRequest groupRequest) {
    log.info("Creating group: {}", groupRequest);
    Group group = new Group();
    group.setName(groupRequest.name());
    return saveGroup(group);
  }

  public UUID saveGroup(Group group) {
    log.info("Saving group: {}", group);
    Group savedGroup = groupRepository.saveAndFlush(group);
    return savedGroup.getId();
  }
}
