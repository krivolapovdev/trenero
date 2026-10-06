package org.trenero.backend.group.external.response

import io.swagger.v3.oas.annotations.media.Schema
import java.time.OffsetDateTime
import java.util.UUID

data class GroupStudentResponse(
  @field:Schema(requiredMode = Schema.RequiredMode.REQUIRED) val id: UUID,
  @field:Schema(requiredMode = Schema.RequiredMode.REQUIRED) val groupId: UUID,
  @field:Schema(requiredMode = Schema.RequiredMode.REQUIRED) val studentId: UUID,
  val leftAt: OffsetDateTime? = null,
)
