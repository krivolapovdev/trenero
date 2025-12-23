package tech.trenero.backend.group.internal.service;

import jakarta.persistence.EntityNotFoundException;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Lazy;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import tech.trenero.backend.common.security.JwtUser;
import tech.trenero.backend.group.internal.entity.Group;
import tech.trenero.backend.group.internal.input.CreateGroupInput;
import tech.trenero.backend.group.internal.repository.GroupRepository;
import tech.trenero.backend.student.external.StudentSpi;

@Service
@Slf4j
@RequiredArgsConstructor
public class GroupGraphQlService {
  private final GroupRepository groupRepository;
  @Lazy private final StudentSpi studentSpi;

  public List<Group> getAllGroups(JwtUser jwtUser) {
    log.info("Getting all groups for ownerId={}", jwtUser.userId());
    return groupRepository.findAllByOwnerId(jwtUser.userId()).stream().toList();
  }

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
  public Group saveGroup(Group group) {
    log.info("Saving group: {}", group);
    return groupRepository.save(group);
  }

  @Transactional
  public Group softDeleteGroup(UUID id, JwtUser jwtUser) {
    log.info("Deleting group: {}", id);
    Group group = findGroupOrThrow(id, jwtUser);
    group.setDeleted(true);
    return groupRepository.save(group);
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
}
