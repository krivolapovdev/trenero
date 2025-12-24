package tech.trenero.backend.group.internal.service;

import java.util.List;
import java.util.Optional;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import tech.trenero.backend.common.dto.GroupDto;
import tech.trenero.backend.common.security.JwtUser;
import tech.trenero.backend.group.internal.entity.Group;
import tech.trenero.backend.group.internal.input.CreateGroupInput;
import tech.trenero.backend.group.internal.mapper.GroupMapper;
import tech.trenero.backend.group.internal.repository.GroupRepository;

@Service
@Slf4j
@RequiredArgsConstructor
public class GroupService {
  private final GroupRepository groupRepository;
  private final GroupMapper groupMapper;

  @Transactional(readOnly = true)
  public List<GroupDto> getAllGroups(JwtUser jwtUser) {
    log.info("Getting all groups for ownerId={}", jwtUser.userId());
    return groupRepository.findAllByOwnerId(jwtUser.userId()).stream()
        .map(groupMapper::toGroupDto)
        .toList();
  }

  @Transactional(readOnly = true)
  public Optional<GroupDto> getGroupById(UUID groupId, JwtUser jwtUser) {
    log.info("Getting group by id={} for ownerId={}", groupId, jwtUser.userId());
    return groupRepository
        .findByIdAndOwnerId(groupId, jwtUser.userId())
        .map(groupMapper::toGroupDto);
  }

  @Transactional
  public GroupDto createGroup(CreateGroupInput input, JwtUser jwtUser) {
    log.info("Creating group: name='{}', ownerId={}", input.name(), jwtUser.userId());
    Group group = Group.builder().ownerId(jwtUser.userId()).name(input.name()).build();
    Group saveGroup = saveGroup(group);
    return groupMapper.toGroupDto(saveGroup);
  }

  @Transactional
  public Optional<GroupDto> softDeleteGroup(UUID id, JwtUser jwtUser) {
    log.info("Deleting group: {}", id);
    return groupRepository
        .findByIdAndOwnerId(id, jwtUser.userId())
        .map(
            group -> {
              group.setDeleted(true);
              return saveGroup(group);
            })
        .map(groupMapper::toGroupDto);
  }

  private Group saveGroup(Group group) {
    log.info("Saving group: {}", group);
    return groupRepository.save(group);
  }
}
