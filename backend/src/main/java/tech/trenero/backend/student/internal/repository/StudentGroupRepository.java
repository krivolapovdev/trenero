package tech.trenero.backend.student.internal.repository;

import java.util.List;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import tech.trenero.backend.student.internal.entity.StudentGroup;
import tech.trenero.backend.student.internal.entity.StudentGroup.StudentGroupId;

@Repository
public interface StudentGroupRepository extends JpaRepository<StudentGroup, StudentGroupId> {
  @Query(
      """
          SELECT sg.groupId
          FROM StudentGroup AS sg
          WHERE sg.studentId = :studentId""")
  List<UUID> findGroupIdsByStudentId(UUID studentId);
}
