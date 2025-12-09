package tech.trenero.backend.student.internal.repository;

import java.util.List;
import java.util.UUID;
import org.jspecify.annotations.NonNull;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import tech.trenero.backend.student.internal.entity.StudentGroup;
import tech.trenero.backend.student.internal.entity.StudentGroup.StudentGroupId;

@Repository
public interface StudentGroupRepository
    extends JpaRepository<@NonNull StudentGroup, @NonNull StudentGroupId> {
  @Query(
      """
            SELECT sg.groupId
            FROM StudentGroup AS sg
            JOIN Student s ON s.id = sg.studentId
            WHERE sg.studentId = :studentId
            AND s.ownerId = :ownerId""")
  List<UUID> findGroupIdsByStudentIdAndOwnerId(
      @Param("studentId") UUID studentId, @Param("ownerId") UUID ownerId);
}
