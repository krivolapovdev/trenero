package org.trenero.backend.visit.external.response

import jakarta.validation.constraints.NotNull
import java.time.OffsetDateTime
import java.util.UUID
import org.trenero.backend.common.domain.VisitStatus
import org.trenero.backend.common.domain.VisitType

data class VisitResponse(
  @get:NotNull val id: UUID,
  @get:NotNull val status: VisitStatus,
  @get:NotNull val type: VisitType,
  @get:NotNull val lessonId: UUID,
  @get:NotNull val studentId: UUID,
  @get:NotNull val createdAt: OffsetDateTime,
)
