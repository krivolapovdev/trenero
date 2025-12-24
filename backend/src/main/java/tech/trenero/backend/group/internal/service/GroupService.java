package tech.trenero.backend.group.internal.service;

import java.util.List;
import java.util.Optional;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import tech.trenero.backend.common.security.JwtUser;
import tech.trenero.backend.group.internal.entity.Group;
import tech.trenero.backend.group.internal.input.CreateGroupInput;
import tech.trenero.backend.group.internal.repository.GroupRepository;

@Service
@Slf4j
@RequiredArgsConstructor
public class GroupService {
  private final GroupRepository groupRepository;

  @Transactional(readOnly = true)
  public List<Group> getAllGroups(JwtUser jwtUser) {
    log.info("Getting all groups for ownerId={}", jwtUser.userId());
    return groupRepository.findAllByOwnerId(jwtUser.userId()).stream().toList();
  }

  @Transactional(readOnly = true)
  public Optional<Group> getGroupById(UUID groupId, JwtUser jwtUser) {
    log.info("Getting group by id={} for ownerId={}", groupId, jwtUser.userId());
    return groupRepository.findByIdAndOwnerId(groupId, jwtUser.userId());
  }

  @Transactional
  public Group createGroup(CreateGroupInput input, JwtUser jwtUser) {
    log.info("Creating group: name='{}', ownerId={}", input.name(), jwtUser.userId());
    Group group = Group.builder().ownerId(jwtUser.userId()).name(input.name()).build();
    return saveGroup(group);
  }

  @Transactional
  public Optional<Group> softDeleteGroup(UUID id, JwtUser jwtUser) {
    log.info("Deleting group: {}", id);
    return groupRepository
        .findByIdAndOwnerId(id, jwtUser.userId())
        .map(
            group -> {
              group.setDeleted(true);
              return saveGroup(group);
            });
  }

  private Group saveGroup(Group group) {
    log.info("Saving group: {}", group);
    return groupRepository.save(group);
  }
}
