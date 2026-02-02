package tech.trenero.backend.group.internal.service;

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
import tech.trenero.backend.common.response.GroupStudentResponse;
import tech.trenero.backend.common.security.JwtUser;
import tech.trenero.backend.group.external.GroupStudentSpi;
import tech.trenero.backend.group.internal.domain.GroupStudent;
import tech.trenero.backend.group.internal.mapper.GroupStudentMapper;
import tech.trenero.backend.group.internal.repository.GroupStudentRepository;

@Service
@RequiredArgsConstructor
@Slf4j
public class GroupStudentService implements GroupStudentSpi {
  @Lazy private final GroupStudentRepository groupStudentRepository;
  @Lazy private final GroupStudentMapper groupStudentMapper;
  @Lazy private final GroupService groupService;
  @Lazy private final GroupStudentService self;

  @Transactional(readOnly = true)
  public List<GroupStudentResponse> getStudentsByGroupId(UUID groupId, JwtUser jwtUser) {
    log.info("Getting students by groupId={}", groupId);
    return groupStudentRepository.findAllByGroupId(groupId, jwtUser.userId()).stream()
        .map(groupStudentMapper::toResponse)
        .toList();
  }

  @Transactional(readOnly = true)
  public Map<UUID, List<GroupStudentResponse>> getStudentsByGroupIds(
      List<UUID> groupIds, JwtUser jwtUser) {
    log.info("Getting students by groupIds={}", groupIds);
    return groupStudentRepository.findAllByGroupIds(groupIds, jwtUser.userId()).stream()
        .map(groupStudentMapper::toResponse)
        .collect(Collectors.groupingBy(GroupStudentResponse::groupId));
  }

  @Transactional(readOnly = true)
  public List<GroupStudentResponse> getGroupsByStudentId(UUID studentId, JwtUser jwtUser) {
    log.info("Getting groups for studentId={}", studentId);
    return groupStudentRepository.findAllByStudentId(studentId, jwtUser.userId()).stream()
        .map(groupStudentMapper::toResponse)
        .toList();
  }

  @Transactional
  @Override
  public GroupStudentResponse addStudentToGroup(
      UUID studentId, UUID groupId, OffsetDateTime joinedAt, JwtUser jwtUser) {
    log.info("Adding studentId={} to groupId={}", studentId, groupId);

    groupService.getGroupById(groupId, jwtUser);

    GroupStudent groupStudent =
        GroupStudent.builder()
            .studentId(studentId)
            .groupId(groupId)
            .ownerId(jwtUser.userId())
            .joinedAt(joinedAt)
            .build();

    GroupStudent savedGroupStudent = self.saveGroupStudent(groupStudent);

    return groupStudentMapper.toResponse(savedGroupStudent);
  }

  @Override
  @Transactional(readOnly = true)
  public Map<UUID, GroupStudentResponse> getGroupStudentsByStudentIds(
      List<UUID> studentIds, JwtUser jwtUser) {
    log.info("Getting groupStudentsByStudentIds={}", studentIds);
    return groupStudentRepository.findAllByStudentIds(studentIds, jwtUser.userId()).stream()
        .map(groupStudentMapper::toResponse)
        .collect(Collectors.toMap(GroupStudentResponse::studentId, Function.identity()));
  }

  @Transactional
  public void addStudentsToGroup(UUID groupId, List<UUID> studentIds, JwtUser jwtUser) {
    for (UUID studentId : studentIds) {
      self.addStudentToGroup(studentId, groupId, OffsetDateTime.now(), jwtUser);
    }
  }

  @Transactional
  public int removeStudentFromGroup(UUID studentId, UUID groupId, JwtUser jwtUser) {
    log.info("Removing studentId={} from groupId={}", studentId, groupId);
    return groupStudentRepository.markStudentLeftGroup(groupId, studentId, jwtUser.userId());
  }

  @Transactional
  public void removeAllStudentsFromGroup(UUID groupId, JwtUser jwtUser) {
    self.softDeleteByGroupId(groupId, jwtUser);
  }

  @Transactional
  public void softDeleteByGroupId(UUID groupId, JwtUser jwtUser) {
    log.info("Soft deleting groupId={}", groupId);
    groupStudentRepository.softDeleteByGroupId(groupId, jwtUser.userId());
  }

  @Transactional
  public GroupStudent saveGroupStudent(GroupStudent groupStudent) {
    log.info("Saving groupStudent: {}", groupStudent);
    return groupStudentRepository.saveAndFlush(groupStudent);
  }
}
