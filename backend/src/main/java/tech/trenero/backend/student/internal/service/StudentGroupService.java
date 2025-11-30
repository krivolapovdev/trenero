package tech.trenero.backend.student.internal.service;

import java.util.List;
import java.util.Set;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import tech.trenero.backend.student.internal.entity.StudentGroup;
import tech.trenero.backend.student.internal.repository.StudentGroupRepository;

@Service
@RequiredArgsConstructor
@Slf4j
public class StudentGroupService {
  private final StudentGroupRepository studentGroupRepository;

  public void assignGroupsToStudent(UUID studentId, Set<UUID> studentGroups) {
    log.info("Assigning groups {} to student {}", studentGroups, studentId);

    List<StudentGroup> studentGroupList =
        studentGroups.stream().map(groupId -> new StudentGroup(studentId, groupId)).toList();

    studentGroupRepository.saveAll(studentGroupList);
  }

  public List<UUID> getGroupIdsByStudentId(UUID studentId) {
    return studentGroupRepository.findGroupIdsByStudentId(studentId);
  }
}
