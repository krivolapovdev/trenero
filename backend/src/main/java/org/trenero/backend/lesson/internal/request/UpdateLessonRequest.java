package org.trenero.backend.lesson.internal.request;

import java.time.LocalDate;
import java.util.List;
import org.trenero.backend.common.domain.StudentVisit;

public record UpdateLessonRequest(LocalDate date, List<StudentVisit> students) {}
