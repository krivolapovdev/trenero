package tech.trenero.backend.visit.internal.repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;
import lombok.NonNull;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import tech.trenero.backend.visit.internal.domain.Visit;

@Repository
public interface VisitRepository extends JpaRepository<@NonNull Visit, @NonNull UUID> {
  @Query(
      """
      SELECT v
      FROM Visit AS v
      WHERE v.ownerId = :ownerId
        AND v.deletedAt IS NULL
      ORDER BY v.createdAt DESC
      """)
  List<Visit> findAllByOwnerId(@Param("ownerId") UUID ownerId);

  @Query(
      """
      SELECT v
      FROM Visit AS v
      WHERE v.id = :visitId
        AND v.ownerId = :ownerId
        AND v.deletedAt IS NULL
      """)
  Optional<Visit> findByIdAndOwnerId(
      @Param("visitId") UUID visitId, @Param("ownerId") UUID ownerId);

  @Query(
      """
      SELECT v
      FROM Visit AS v
      WHERE v.lessonId = :lessonId
        AND v.studentId = :studentId
        AND v.ownerId = :ownerId
        AND v.deletedAt IS NULL
      """)
  Optional<Visit> findByLessonIdAndStudentIdAndOwnerId(
      @Param("lessonId") UUID lessonId,
      @Param("studentId") UUID studentId,
      @Param("ownerId") UUID ownerId);

  @Query(
      """
      SELECT v
      FROM Visit AS v
      WHERE v.ownerId = :ownerId
        AND v.studentId = :studentId
        AND v.deletedAt IS NULL
      """)
  List<Visit> findAllByStudentIdAndOwnerId(
      @Param("studentId") UUID studentId, @Param("ownerId") UUID ownerId);

  @Query(
      """
      SELECT v
      FROM Visit AS v
      WHERE v.ownerId = :ownerId
        AND v.lessonId = :lessonId
        AND v.deletedAt IS NULL
      """)
  List<Visit> findAllByLessonIdAndOwnerId(
      @Param("lessonId") UUID lessonId, @Param("ownerId") UUID ownerId);

  @Query(
      """
      SELECT v
      FROM Visit v
      WHERE v.ownerId = :ownerId
        AND v.studentId IN :studentIds
        AND v.deletedAt IS NULL
      ORDER BY v.createdAt DESC
      """)
  List<Visit> findAllByStudentIdsAndOwnerId(
      @Param("studentIds") List<UUID> studentIds, @Param("ownerId") UUID ownerId);
}
