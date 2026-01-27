package tech.trenero.backend.lesson.internal.request;

import java.time.OffsetDateTime;
import java.util.List;
import java.util.UUID;

public record CreateLessonRequest(
    UUID groupId, OffsetDateTime startDateTime, List<LessonStudentRequest> students) {}
