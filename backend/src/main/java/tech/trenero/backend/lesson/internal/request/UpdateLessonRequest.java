package tech.trenero.backend.lesson.internal.request;

import java.time.OffsetDateTime;
import java.util.List;
import java.util.Optional;

public record UpdateLessonRequest(
    Optional<OffsetDateTime> startDateTime, Optional<List<LessonStudentRequest>> students) {}
