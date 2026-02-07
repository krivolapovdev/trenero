package org.trenero.backend.group.internal.service;

import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.function.Function;
import java.util.stream.Collectors;
import lombok.NonNull;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Lazy;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.trenero.backend.common.response.GroupStudentResponse;
import org.trenero.backend.common.security.JwtUser;
import org.trenero.backend.group.external.GroupStudentSpi;
import org.trenero.backend.group.internal.domain.GroupStudent;
import org.trenero.backend.group.internal.mapper.GroupStudentMapper;
import org.trenero.backend.group.internal.repository.GroupStudentRepository;

@Service
@RequiredArgsConstructor
@Slf4j
public class GroupStudentService implements GroupStudentSpi {
  private final GroupStudentRepository groupStudentRepository;
  private final GroupStudentMapper groupStudentMapper;

  @Lazy private final GroupService groupService;
  @Lazy private final GroupStudentService self;

  @Transactional(readOnly = true)
  public @NonNull List<GroupStudentResponse> getStudentsByGroupId(
      @NonNull UUID groupId, @NonNull JwtUser jwtUser) {
    log.info("Getting students by group id: groupId={}; user={}", groupId, jwtUser);
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
  public @NonNull List<GroupStudentResponse> getGroupsByStudentId(
      @NonNull UUID studentId, @NonNull JwtUser jwtUser) {
    log.info("Getting groups by student id: studentId={}; user={}", studentId, jwtUser);
    return groupStudentRepository.findAllByStudentId(studentId, jwtUser.userId()).stream()
        .map(groupStudentMapper::toResponse)
        .toList();
  }

  @Transactional
  @Override
  public @NonNull GroupStudentResponse addStudentToGroup(
      @NonNull UUID studentId, @NonNull UUID groupId, @NonNull JwtUser jwtUser) {
    log.info(
        "Adding student to group: studentId={}; groupId={}; user={}", studentId, groupId, jwtUser);

    groupService.getGroupById(groupId, jwtUser);

    GroupStudent groupStudent =
        GroupStudent.builder()
            .studentId(studentId)
            .groupId(groupId)
            .ownerId(jwtUser.userId())
            .build();

    GroupStudent savedGroupStudent = self.saveGroupStudent(groupStudent);

    return groupStudentMapper.toResponse(savedGroupStudent);
  }

  @Override
  @Transactional(readOnly = true)
  public @NonNull Map<UUID, GroupStudentResponse> getGroupStudentsByStudentIds(
      @NonNull List<UUID> studentIds, @NonNull JwtUser jwtUser) {
    log.info("Getting group students by student ids: studentIds={}; user={}", studentIds, jwtUser);
    return groupStudentRepository.findAllByStudentIds(studentIds, jwtUser.userId()).stream()
        .map(groupStudentMapper::toResponse)
        .collect(Collectors.toMap(GroupStudentResponse::studentId, Function.identity()));
  }

  @Transactional
  public void addStudentsToGroup(UUID groupId, List<UUID> studentIds, JwtUser jwtUser) {
    log.info(
        "Batch adding students to group: groupId={}; studentIds={}; user={}",
        groupId,
        studentIds,
        jwtUser);

    groupService.getGroupById(groupId, jwtUser);

    List<GroupStudent> groupStudents =
        studentIds.stream()
            .map(
                studentId ->
                    GroupStudent.builder()
                        .studentId(studentId)
                        .groupId(groupId)
                        .ownerId(jwtUser.userId())
                        .build())
            .toList();

    groupStudentRepository.saveAll(groupStudents);
  }

  @Transactional
  public void removeStudentFromGroup(
      @NonNull UUID studentId, @NonNull UUID groupId, @NonNull JwtUser jwtUser) {
    log.info("Removing all students from group: groupId={}; user={}", groupId, jwtUser);
    self.softDeleteByStudentIdAndGroupId(studentId, groupId, jwtUser);
  }

  @Transactional
  public void removeAllStudentsFromGroup(UUID groupId, JwtUser jwtUser) {
    self.softDeleteByGroupId(groupId, jwtUser);
  }

  @Transactional
  public void softDeleteByGroupId(UUID groupId, JwtUser jwtUser) {
    log.info(
        "Soft deleting group student links by group id: groupId={}; user={}", groupId, jwtUser);
    groupStudentRepository.softDeleteByGroupId(groupId, jwtUser.userId());
  }

  @Transactional
  public void softDeleteByStudentIdAndGroupId(UUID studentId, UUID groupId, JwtUser jwtUser) {
    log.info(
        "Soft deleting group student link: studentId={}; groupId={}; user={}",
        studentId,
        groupId,
        jwtUser);
    groupStudentRepository.softDeleteByStudentIdAndGroupId(groupId, studentId, jwtUser.userId());
  }

  @Transactional
  public GroupStudent saveGroupStudent(GroupStudent groupStudent) {
    log.info("Saving group student link: groupStudent={}", groupStudent);
    return groupStudentRepository.saveAndFlush(groupStudent);
  }
}
