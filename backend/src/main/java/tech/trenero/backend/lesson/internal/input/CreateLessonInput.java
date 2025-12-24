package tech.trenero.backend.lesson.internal.input;

import java.time.OffsetDateTime;
import java.util.UUID;

public record CreateLessonInput(UUID groupId, OffsetDateTime startDateTime) {}
