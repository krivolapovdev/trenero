package tech.trenero.backend.group.internal.service;

import graphql.schema.DataFetchingEnvironment;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Lazy;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import tech.trenero.backend.codegen.types.CreateGroupInput;
import tech.trenero.backend.codegen.types.UpdateGroupInput;
import tech.trenero.backend.common.security.JwtUser;
import tech.trenero.backend.group.internal.entity.Group;
import tech.trenero.backend.group.internal.mapper.GroupMapper;
import tech.trenero.backend.group.internal.repository.GroupRepository;
import tech.trenero.backend.student.external.StudentSpi;

@Service
@Slf4j
@RequiredArgsConstructor
public class GroupService {
  private final GroupRepository groupRepository;
  private final GroupMapper groupMapper;
  @Lazy private final StudentSpi studentSpi;

  @Transactional(readOnly = true)
  public List<tech.trenero.backend.codegen.types.Group> getAllGroups(JwtUser jwtUser) {
    log.info("Getting all groups for ownerId={}", jwtUser.userId());
    return groupRepository.findAllByOwnerId(jwtUser.userId()).stream()
        .map(groupMapper::toGraphql)
        .toList();
  }

  @Transactional(readOnly = true)
  public Optional<tech.trenero.backend.codegen.types.Group> findGroupById(
      UUID groupId, JwtUser jwtUser) {
    log.info("Getting group by id={} for ownerId={}", groupId, jwtUser.userId());
    return groupRepository
        .findByIdAndOwnerId(groupId, jwtUser.userId())
        .map(groupMapper::toGraphql);
  }

  @Transactional
  public tech.trenero.backend.codegen.types.Group createGroup(
      CreateGroupInput input, JwtUser jwtUser) {
    log.info("Creating group: name='{}', ownerId={}", input.getName(), jwtUser.userId());

    Group group = groupMapper.toGroup(input, jwtUser.userId());
    Group saveGroup = saveGroup(group);

    studentSpi.assignGroupToStudents(saveGroup.getId(), input.getStudentIds(), jwtUser);

    return groupMapper.toGraphql(saveGroup);
  }

  @Transactional
  public Optional<tech.trenero.backend.codegen.types.Group> updateGroup(
      UUID groupId, UpdateGroupInput input, DataFetchingEnvironment environment, JwtUser jwtUser) {

    if (input.hasStudentIds()) {
      studentSpi.editStudentsGroup(groupId, input.getStudentIds(), jwtUser);
    }

    return groupRepository
        .findByIdAndOwnerId(groupId, jwtUser.userId())
        .map(group -> groupMapper.updateGroup(group, input, environment))
        .map(this::saveGroup)
        .map(groupMapper::toGraphql);
  }

  @Transactional
  public Optional<tech.trenero.backend.codegen.types.Group> softDeleteGroup(
      UUID id, JwtUser jwtUser) {
    log.info("Deleting group: {}", id);

    studentSpi.removeGroupFromStudents(id, jwtUser);

    return groupRepository
        .findByIdAndOwnerId(id, jwtUser.userId())
        .map(
            group -> {
              group.setDeletedAt(OffsetDateTime.now());
              return saveGroup(group);
            })
        .map(groupMapper::toGraphql);
  }

  private Group saveGroup(Group group) {
    log.info("Saving group: {}", group);
    return groupRepository.saveAndFlush(group);
  }
}
