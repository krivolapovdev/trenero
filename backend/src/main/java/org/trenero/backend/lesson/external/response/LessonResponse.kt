package org.trenero.backend.lesson.external.response

import io.swagger.v3.oas.annotations.media.Schema
import java.time.LocalDate
import java.time.OffsetDateTime
import java.util.UUID

data class LessonResponse(
  @field:Schema(requiredMode = Schema.RequiredMode.REQUIRED) val id: UUID,
  @field:Schema(requiredMode = Schema.RequiredMode.REQUIRED) val date: LocalDate,
  @field:Schema(requiredMode = Schema.RequiredMode.REQUIRED) val createdAt: OffsetDateTime,
  val groupId: UUID? = null,
)
