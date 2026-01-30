package tech.trenero.backend.student.internal.repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;
import lombok.NonNull;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;
import tech.trenero.backend.student.internal.model.Student;

@Repository
public interface StudentRepository extends JpaRepository<@NonNull Student, @NonNull UUID> {
  @Query(
      """
      SELECT s
      FROM Student AS s
      WHERE s.ownerId = :ownerId
        AND s.deletedAt IS NULL
      ORDER BY s.fullName
      """)
  List<Student> findAllByOwnerId(@Param("ownerId") UUID ownerId);

  @Query(
      """
      SELECT s
      FROM Student AS s
      WHERE s.id = :studentId
        AND s.ownerId = :ownerId
        AND s.deletedAt IS NULL
      """)
  Optional<Student> findByIdAndOwnerId(
      @Param("studentId") UUID studentId, @Param("ownerId") UUID ownerId);

  @Query(
      """
      SELECT DISTINCT s
      FROM Student AS s
      WHERE s.ownerId = :ownerId
        AND s.groupId = :groupId
        AND s.deletedAt IS NULL
      ORDER BY s.fullName
      """)
  List<Student> findAllByGroupIdAndOwnerId(
      @Param("groupId") UUID groupId, @Param("ownerId") UUID ownerId);

  @Query(
      """
      SELECT s
      FROM Student AS s
      WHERE s.id IN :studentIds
        AND s.ownerId = :ownerId
        AND s.deletedAt IS NULL
      """)
  List<Student> findAllByIdsAndOwnerId(
      @Param("studentIds") List<UUID> studentIds, @Param("ownerId") UUID ownerId);

  @Modifying
  @Transactional
  @Query(
      """
      UPDATE Student AS s
      SET s.groupId = :groupId
      WHERE s.id IN :studentIds
        AND s.ownerId = :ownerId
        AND s.deletedAt IS NULL
      """)
  int setGroupIdForStudents(
      @Param("groupId") UUID groupId,
      @Param("studentIds") List<UUID> studentIds,
      @Param("ownerId") UUID ownerId);

  @Query(
      """
      SELECT COUNT(s)
      FROM Student AS s
      WHERE s.groupId = :groupId
        AND s.ownerId = :ownerId
        AND s.deletedAt IS NULL
      """)
  int countByGroupIdAndOwnerId(@Param("groupId") UUID groupId, @Param("ownerId") UUID ownerId);

  @Query(
      """
       SELECT s
       FROM Student AS s
       WHERE s.ownerId = :ownerId
         AND s.groupId IN :groupIds
         AND s.deletedAt IS NULL
       ORDER BY s.createdAt DESC
       """)
  List<Student> findAllByGroupIdsAndOwnerId(
      @Param("groupIds") List<UUID> groupIds, @Param("ownerId") UUID ownerId);
}
