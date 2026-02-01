package tech.trenero.backend.lesson.internal.request;

import java.time.OffsetDateTime;
import java.util.List;

public record UpdateLessonRequest(
    OffsetDateTime startDateTime, List<LessonStudentRequest> students) {}
