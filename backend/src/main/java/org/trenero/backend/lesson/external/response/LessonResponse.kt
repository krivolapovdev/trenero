package org.trenero.backend.lesson.external.response

import jakarta.validation.constraints.NotNull
import java.time.LocalDate
import java.time.OffsetDateTime
import java.util.UUID

data class LessonResponse(
  @get:NotNull val id: UUID,
  @get:NotNull val groupId: UUID,
  @get:NotNull val date: LocalDate,
  @get:NotNull val createdAt: OffsetDateTime,
)
