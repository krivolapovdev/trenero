package org.trenero.backend.lesson.internal.repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;
import lombok.NonNull;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import org.trenero.backend.lesson.internal.domain.Lesson;

@Repository
public interface LessonRepository extends JpaRepository<@NonNull Lesson, @NonNull UUID> {
  @Query(
      """
      SELECT l
      FROM Lesson AS l
      WHERE l.ownerId = :ownerId
        AND l.deletedAt IS NULL
      ORDER BY l.createdAt DESC
      """)
  List<Lesson> findAllByOwnerId(@Param("ownerId") UUID ownerId);

  @Query(
      """
      SELECT l
      FROM Lesson AS l
      WHERE l.ownerId = :ownerId
        AND l.groupId = :groupId
        AND l.deletedAt IS NULL
      ORDER BY l.createdAt DESC
      """)
  List<Lesson> findAllByGroupIdAndOwnerId(
      @Param("groupId") UUID groupId, @Param("ownerId") UUID ownerId);

  @Query(
      """
      SELECT l
      FROM Lesson AS l
      WHERE l.id = :lessonId
        AND l.ownerId = :ownerId
        AND l.deletedAt IS NULL
      """)
  Optional<Lesson> findByIdAndOwnerId(
      @Param("lessonId") UUID lessonId, @Param("ownerId") UUID ownerId);

  @Query(
      """
      SELECT l
      FROM Lesson AS l
      WHERE l.groupId = :groupId
        AND l.ownerId = :ownerId
        AND l.deletedAt IS NULL
      ORDER BY l.startDateTime DESC
      LIMIT 1
      """)
  Optional<Lesson> findLastGroupLesson(
      @Param("groupId") UUID groupId, @Param("ownerId") UUID ownerId);

  @Query(
      """
        SELECT l
        FROM Lesson l
        WHERE l.ownerId = :ownerId
          AND l.groupId IN :groupIds
          AND l.deletedAt IS NULL
          AND l.startDateTime = (
              SELECT MAX(subl.startDateTime)
              FROM Lesson subl
              WHERE subl.groupId = l.groupId
                AND subl.ownerId = l.ownerId
                AND subl.deletedAt IS NULL
          )
        """)
  List<Lesson> findLastLessonsByGroupIdsAndOwnerId(
      @Param("groupIds") List<UUID> groupIds, @Param("ownerId") UUID ownerId);
}
