package org.trenero.backend.group.external.response

import jakarta.validation.constraints.NotNull
import java.math.BigDecimal
import java.time.OffsetDateTime
import java.util.UUID

data class GroupResponse(
  @get:NotNull val id: UUID,
  @get:NotNull val name: String,
  val defaultPrice: BigDecimal? = null,
  val note: String? = null,
  @get:NotNull val createdAt: OffsetDateTime,
)
