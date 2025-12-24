package tech.trenero.backend.lesson.internal.input;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.PastOrPresent;
import java.time.OffsetDateTime;
import java.util.UUID;

public record CreateLessonInput(
    @NotNull UUID groupId, @NotNull @PastOrPresent OffsetDateTime startDateTime) {}
