package tech.trenero.backend.attendance.internal.repository;

import java.util.UUID;
import org.jspecify.annotations.NonNull;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import tech.trenero.backend.attendance.internal.entity.Lesson;

@Repository
public interface LessonRepository extends JpaRepository<@NonNull Lesson, @NonNull UUID> {}
