package org.trenero.backend.student.internal.response

import io.swagger.v3.oas.annotations.media.Schema
import org.trenero.backend.lesson.external.response.LessonResponse
import org.trenero.backend.visit.external.response.VisitResponse

data class VisitWithLessonResponse(
  @field:Schema(requiredMode = Schema.RequiredMode.REQUIRED) val visit: VisitResponse,
  @field:Schema(requiredMode = Schema.RequiredMode.REQUIRED) val lesson: LessonResponse,
)
