package tech.trenero.backend.lesson.internal.repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;
import lombok.NonNull;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import tech.trenero.backend.lesson.internal.entity.Lesson;

@Repository
public interface LessonRepository extends JpaRepository<@NonNull Lesson, @NonNull UUID> {
  @Query(
      """
        SELECT l
        FROM Lesson AS l
        WHERE l.ownerId = :ownerId
          AND l.deletedAt IS NULL
        ORDER BY l.createdAt DESC""")
  List<Lesson> findAllByOwnerId(@Param("ownerId") UUID ownerId);

  @Query(
      """
        SELECT l
        FROM Lesson AS l
        WHERE l.ownerId = :ownerId
          AND l.groupId = :groupId
          AND l.deletedAt IS NULL
        ORDER BY l.createdAt DESC""")
  List<Lesson> findAllByGroupIdAndOwnerId(
      @Param("groupId") UUID groupId, @Param("ownerId") UUID ownerId);

  @Query(
      """
        SELECT l
        FROM Lesson AS l
        WHERE l.id = :lessonId
          AND l.ownerId = :ownerId
          AND l.deletedAt IS NULL""")
  Optional<Lesson> findByIdAndOwnerId(
      @Param("lessonId") UUID lessonId, @Param("ownerId") UUID ownerId);
}
