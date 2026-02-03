package tech.trenero.backend.lesson.internal.request;

import java.time.OffsetDateTime;
import java.util.List;
import tech.trenero.backend.common.domain.StudentVisit;

public record UpdateLessonRequest(OffsetDateTime startDateTime, List<StudentVisit> students) {}
