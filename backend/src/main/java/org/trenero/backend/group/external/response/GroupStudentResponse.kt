package org.trenero.backend.group.external.response

import jakarta.validation.constraints.NotNull
import java.time.OffsetDateTime
import java.util.UUID

data class GroupStudentResponse(
  @get:NotNull val id: UUID,
  @get:NotNull val groupId: UUID,
  @get:NotNull val studentId: UUID,
  val leftAt: OffsetDateTime?,
)
