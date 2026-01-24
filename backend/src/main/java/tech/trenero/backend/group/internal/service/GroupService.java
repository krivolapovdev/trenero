package tech.trenero.backend.group.internal.service;

import jakarta.persistence.EntityNotFoundException;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Lazy;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import tech.trenero.backend.common.response.GroupResponse;
import tech.trenero.backend.common.response.LessonResponse;
import tech.trenero.backend.common.response.StudentResponse;
import tech.trenero.backend.common.security.JwtUser;
import tech.trenero.backend.group.external.GroupSpi;
import tech.trenero.backend.group.internal.entity.Group;
import tech.trenero.backend.group.internal.mapper.GroupMapper;
import tech.trenero.backend.group.internal.repository.GroupRepository;
import tech.trenero.backend.group.internal.request.CreateGroupRequest;
import tech.trenero.backend.group.internal.request.UpdateGroupRequest;
import tech.trenero.backend.lesson.external.LessonSpi;
import tech.trenero.backend.student.external.StudentSpi;

@Service
@Slf4j
@RequiredArgsConstructor
public class GroupService implements GroupSpi {
  private final GroupRepository groupRepository;
  private final GroupMapper groupMapper;
  @Lazy private final StudentSpi studentSpi;
  @Lazy private final LessonSpi lessonSpi;

  @Transactional(readOnly = true)
  public List<GroupResponse> getAllGroups(JwtUser jwtUser) {
    log.info("Getting all groups for ownerId={}", jwtUser.userId());
    return groupRepository.findAllByOwnerId(jwtUser.userId()).stream()
        .map(groupMapper::toResponse)
        .toList();
  }

  @Transactional(readOnly = true)
  public GroupResponse getGroupById(UUID groupId, JwtUser jwtUser) {
    log.info("Getting group by id={} for ownerId={}", groupId, jwtUser.userId());
    return groupRepository
        .findByIdAndOwnerId(groupId, jwtUser.userId())
        .map(groupMapper::toResponse)
        .orElseThrow(() -> new EntityNotFoundException("Group not found: " + groupId));
  }

  @Transactional(readOnly = true)
  public List<StudentResponse> getStudentsByGroupId(UUID groupId, JwtUser jwtUser) {
    return studentSpi.getStudentsByGroupId(groupId, jwtUser);
  }

  @Transactional(readOnly = true)
  public List<LessonResponse> getLessonsByGroupId(UUID groupId, JwtUser jwtUser) {
    return lessonSpi.getLessonsByGroupId(groupId, jwtUser);
  }

  @Transactional
  public GroupResponse createGroup(CreateGroupRequest request, JwtUser jwtUser) {
    log.info("Creating group: name='{}', ownerId={}", request.name(), jwtUser.userId());

    Group group = groupMapper.toGroup(request, jwtUser.userId());
    Group saveGroup = saveGroup(group);

    studentSpi.assignGroupToStudents(saveGroup.getId(), request.studentIds(), jwtUser);

    return groupMapper.toResponse(saveGroup);
  }

  @Transactional
  public GroupResponse updateGroup(UUID groupId, UpdateGroupRequest request, JwtUser jwtUser) {
    log.info("Updating group: name='{}', ownerId={}", request.name(), jwtUser.userId());

    if (request.studentIds().isPresent()) {
      studentSpi.editStudentsGroup(groupId, request.studentIds().get(), jwtUser);
    }

    return groupRepository
        .findByIdAndOwnerId(groupId, jwtUser.userId())
        .map(group -> groupMapper.updateGroup(group, request))
        .map(this::saveGroup)
        .map(groupMapper::toResponse)
        .orElseThrow(() -> new EntityNotFoundException("Group not found: " + groupId));
  }

  @Transactional
  public void softDeleteGroup(UUID id, JwtUser jwtUser) {
    log.info("Deleting group: {}", id);

    studentSpi.removeGroupFromStudents(id, jwtUser);

    groupRepository
        .findByIdAndOwnerId(id, jwtUser.userId())
        .map(
            group -> {
              group.setDeletedAt(OffsetDateTime.now());
              return saveGroup(group);
            })
        .orElseThrow(() -> new EntityNotFoundException("Group not found: " + id));
  }

  @Transactional
  public void deleteGroupLesson(UUID lessonId, JwtUser jwtUser) {
    lessonSpi.deleteLesson(lessonId, jwtUser);
  }

  private Group saveGroup(Group group) {
    log.info("Saving group: {}", group);
    return groupRepository.saveAndFlush(group);
  }
}
