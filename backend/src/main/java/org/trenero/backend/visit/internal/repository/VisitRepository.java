package org.trenero.backend.visit.internal.repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;
import lombok.NonNull;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import org.trenero.backend.visit.internal.domain.Visit;

@Repository
public interface VisitRepository extends JpaRepository<@NonNull Visit, @NonNull UUID> {

  @Query(
      """
          SELECT v
          FROM Visit AS v
          WHERE v.ownerId = :ownerId
          ORDER BY v.createdAt DESC
          """)
  List<Visit> findAllByOwnerId(@Param("ownerId") UUID ownerId);

  @Query(
      """
          SELECT v
          FROM Visit AS v
          WHERE v.id = :visitId
            AND v.ownerId = :ownerId
          """)
  Optional<Visit> findByIdAndOwnerId(
      @Param("visitId") UUID visitId, @Param("ownerId") UUID ownerId);

  @Query(
      """
          SELECT v
          FROM Visit AS v
          WHERE v.ownerId = :ownerId
            AND v.studentId = :studentId
          """)
  List<Visit> findAllByStudentIdAndOwnerId(
      @Param("studentId") UUID studentId, @Param("ownerId") UUID ownerId);

  @Query(
      """
          SELECT v
          FROM Visit AS v
          WHERE v.ownerId = :ownerId
            AND v.lessonId = :lessonId
          """)
  List<Visit> findAllByLessonIdAndOwnerId(
      @Param("lessonId") UUID lessonId, @Param("ownerId") UUID ownerId);

  @Query(
      """
          SELECT v
          FROM Visit AS v
          WHERE v.ownerId = :ownerId
            AND v.studentId IN :studentIds
          ORDER BY v.createdAt DESC
          """)
  List<Visit> findAllByStudentIdsAndOwnerId(
      @Param("studentIds") List<UUID> studentIds, @Param("ownerId") UUID ownerId);
}
