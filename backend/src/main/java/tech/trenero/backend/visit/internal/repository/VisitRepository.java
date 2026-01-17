package tech.trenero.backend.visit.internal.repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;
import lombok.NonNull;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import tech.trenero.backend.visit.internal.entity.Visit;

@Repository
public interface VisitRepository extends JpaRepository<@NonNull Visit, @NonNull UUID> {
  @Query(
      """
        SELECT a
        FROM Visit AS a
        WHERE a.ownerId = :ownerId
          AND a.deletedAt IS NULL
        ORDER BY a.createdAt DESC""")
  List<Visit> findAllByOwnerId(@Param("ownerId") UUID ownerId);

  @Query(
      """
        SELECT a
        FROM Visit AS a
        WHERE a.id = :visitId
          AND a.ownerId = :ownerId
          AND a.deletedAt IS NULL""")
  Optional<Visit> findByIdAndOwnerId(
      @Param("visitId") UUID visitId, @Param("ownerId") UUID ownerId);

  @Query(
      """
        SELECT a
        FROM Visit AS a
        WHERE a.ownerId = :ownerId
          AND a.studentId = :studentId
          AND a.deletedAt IS NULL""")
  List<Visit> findAllByStudentIdAndOwnerId(
      @Param("studentId") UUID studentId, @Param("ownerId") UUID ownerId);

  @Query(
      """
        SELECT a
        FROM Visit AS a
        WHERE a.ownerId = :ownerId
          AND a.lessonId = :lessonId
          AND a.deletedAt IS NULL""")
  List<Visit> findAllByLessonIdAndOwnerId(
      @Param("lessonId") UUID lessonId, @Param("ownerId") UUID ownerId);
}
