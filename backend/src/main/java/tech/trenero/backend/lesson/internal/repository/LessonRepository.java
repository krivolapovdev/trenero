package tech.trenero.backend.lesson.internal.repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;
import lombok.NonNull;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.graphql.data.GraphQlRepository;
import tech.trenero.backend.common.dto.LessonDto;
import tech.trenero.backend.lesson.internal.entity.Lesson;

@GraphQlRepository
public interface LessonRepository extends JpaRepository<@NonNull Lesson, @NonNull UUID> {
  @Query(
      """
        SELECT l
        FROM Lesson AS l
        WHERE l.ownerId = :ownerId
        ORDER BY l.createdAt DESC""")
  List<Lesson> findAllByOwnerId(@Param("ownerId") UUID ownerId);

  @Query(
      """
        SELECT l
        FROM Lesson AS l
        WHERE l.groupId = :groupId
          AND l.ownerId = :ownerId
        ORDER BY l.createdAt DESC""")
  List<Lesson> findAllByGroupIdAndOwnerId(
      @Param("groupId") UUID groupId, @Param("ownerId") UUID ownerId);

  @Query(
      """
        SELECT l
        FROM Lesson AS l
        WHERE l.id = :lessonId
          AND l.ownerId = :ownerId""")
  Optional<Lesson> findByIdAndOwnerId(
      @Param("lessonId") UUID lessonId, @Param("ownerId") UUID ownerId);

  @Query(
      """
        SELECT l
        FROM Lesson AS l
        WHERE l.groupId = :groupId
          AND l.ownerId = :ownerId
        ORDER BY l.startDateTime DESC
        LIMIT 1""")
  Optional<LessonDto> findLastLesson(
      @Param("groupId") UUID groupId, @Param("ownerId") UUID ownerId);
}
