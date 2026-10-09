package org.trenero.backend.group.internal.service;

import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.time.ZoneOffset;
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
import org.trenero.backend.common.security.JwtUser;
import org.trenero.backend.group.external.response.GroupStudentResponse;
import org.trenero.backend.group.external.spi.GroupStudentSpi;
import org.trenero.backend.group.internal.domain.GroupStudent;
import org.trenero.backend.group.internal.domain.GroupStudentCount;
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
    return groupStudentRepository.findAllByGroupId(groupId, jwtUser.id()).stream()
        .map(groupStudentMapper::toResponse)
        .toList();
  }

  @Transactional(readOnly = true)
  public @NonNull List<GroupStudentResponse> getGroupsByStudentId(
      @NonNull UUID studentId, @NonNull JwtUser jwtUser) {
    log.info("Getting groups by student id: studentId={}; user={}", studentId, jwtUser);
    return groupStudentRepository.findAllByStudentId(studentId, jwtUser.id()).stream()
        .map(groupStudentMapper::toResponse)
        .toList();
  }

  @Transactional(readOnly = true)
  public @NonNull Map<UUID, Long> getStudentCountsByGroupIds(
      @NonNull List<UUID> groupIds, @NonNull JwtUser jwtUser) {
    log.info("Getting student counts by groupIds={}", groupIds);
    if (groupIds.isEmpty()) {
      return Map.of();
    }
    return groupStudentRepository.countStudentsByGroupIds(groupIds, jwtUser.id()).stream()
        .collect(Collectors.toMap(GroupStudentCount::getGroupId, GroupStudentCount::getCount));
  }

  @Transactional
  @Override
  public void addStudentToGroup(
      @NonNull UUID studentId,
      @NonNull UUID groupId,
      LocalDate joinedAt,
      @NonNull JwtUser jwtUser) {
    log.info(
        "Adding student to group: studentId={}; groupId={}; joinedAt={}; user={}",
        studentId,
        groupId,
        joinedAt,
        jwtUser);

    groupService.getGroupById(groupId, jwtUser);

    GroupStudent groupStudent =
        GroupStudent.builder()
            .studentId(studentId)
            .groupId(groupId)
            .ownerId(jwtUser.id())
            .joinedAt(toJoinedAt(joinedAt))
            .build();

    GroupStudent savedGroupStudent = self.saveGroupStudent(groupStudent);

    groupStudentMapper.toResponse(savedGroupStudent);
  }

  /**
   * The stored instant of joining a group. The user picks a calendar day, so it is anchored to the
   * start of that day in UTC; when no day is given the current day is used.
   */
  private static OffsetDateTime toJoinedAt(LocalDate joinedAt) {
    return (joinedAt != null ? joinedAt : LocalDate.now())
        .atStartOfDay(ZoneOffset.UTC)
        .toOffsetDateTime();
  }

  @Override
  @Transactional(readOnly = true)
  public @NonNull Map<UUID, GroupStudentResponse> getGroupStudentsByStudentIds(
      @NonNull List<UUID> studentIds, @NonNull JwtUser jwtUser) {
    log.info("Getting group students by student ids: studentIds={}; user={}", studentIds, jwtUser);
    return groupStudentRepository.findAllByStudentIds(studentIds, jwtUser.id()).stream()
        .map(groupStudentMapper::toResponse)
        .collect(Collectors.toMap(GroupStudentResponse::getStudentId, Function.identity()));
  }

  @Transactional
  public void addStudentsToGroup(
      @NonNull UUID groupId, @NonNull List<UUID> studentIds, @NonNull JwtUser jwtUser) {
    log.info(
        "Batch adding students to group: groupId={}; studentIds={}; user={}",
        groupId,
        studentIds,
        jwtUser);

    if (studentIds.isEmpty()) {
      return;
    }

    groupService.getGroupById(groupId, jwtUser);

    List<GroupStudent> groupStudents =
        studentIds.stream()
            .map(
                studentId ->
                    GroupStudent.builder()
                        .studentId(studentId)
                        .groupId(groupId)
                        .ownerId(jwtUser.id())
                        .joinedAt(OffsetDateTime.now(ZoneOffset.UTC))
                        .build())
            .toList();

    groupStudentRepository.saveAll(groupStudents);
  }

  @Transactional
  public void removeStudentFromGroup(
      @NonNull UUID studentId, @NonNull UUID groupId, @NonNull JwtUser jwtUser) {
    log.info("Removing all students from group: groupId={}; user={}", groupId, jwtUser);
    self.deleteByStudentIdAndGroupId(studentId, groupId, jwtUser);
  }

  @Transactional
  public void removeAllStudentsFromGroup(@NonNull UUID groupId, @NonNull JwtUser jwtUser) {
    self.deleteByGroupId(groupId, jwtUser);
  }

  @Transactional
  public void deleteByGroupId(@NonNull UUID groupId, @NonNull JwtUser jwtUser) {
    log.info("Deleting group student links by group id: groupId={}; user={}", groupId, jwtUser);
    groupStudentRepository.deleteByGroupId(groupId, jwtUser.id());
  }

  @Transactional
  public void deleteByStudentIdAndGroupId(
      @NonNull UUID studentId, @NonNull UUID groupId, @NonNull JwtUser jwtUser) {
    log.info(
        "Deleting group student link: studentId={}; groupId={}; user={}",
        studentId,
        groupId,
        jwtUser);
    groupStudentRepository.deleteByStudentIdAndGroupId(groupId, studentId, jwtUser.id());
  }

  @Transactional
  public @NonNull GroupStudent saveGroupStudent(@NonNull GroupStudent groupStudent) {
    log.info("Saving group student link: groupStudent={}", groupStudent);
    return groupStudentRepository.saveAndFlush(groupStudent);
  }
}
