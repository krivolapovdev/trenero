package org.trenero.backend.visit.external.response

import io.swagger.v3.oas.annotations.media.Schema
import java.time.OffsetDateTime
import java.util.UUID
import org.trenero.backend.common.domain.VisitStatus
import org.trenero.backend.common.domain.VisitType

data class VisitResponse(
  @field:Schema(requiredMode = Schema.RequiredMode.REQUIRED) val id: UUID,
  @field:Schema(requiredMode = Schema.RequiredMode.REQUIRED) val status: VisitStatus,
  @field:Schema(requiredMode = Schema.RequiredMode.REQUIRED) val type: VisitType,
  @field:Schema(requiredMode = Schema.RequiredMode.REQUIRED) val lessonId: UUID,
  @field:Schema(requiredMode = Schema.RequiredMode.REQUIRED) val studentId: UUID,
  @field:Schema(requiredMode = Schema.RequiredMode.REQUIRED) val createdAt: OffsetDateTime,
)
