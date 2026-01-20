package tech.trenero.backend.lesson.internal.request;

import java.util.UUID;

public record LessonStudentRequest(UUID studentId, Boolean present) {}
