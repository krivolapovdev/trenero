package org.trenero.backend.group.external.response

import io.swagger.v3.oas.annotations.media.Schema
import java.math.BigDecimal
import java.time.OffsetDateTime
import java.util.UUID

data class GroupResponse(
  @field:Schema(requiredMode = Schema.RequiredMode.REQUIRED) val id: UUID,
  @field:Schema(requiredMode = Schema.RequiredMode.REQUIRED) val name: String,
  val defaultPrice: BigDecimal? = null,
  val note: String? = null,
  @field:Schema(requiredMode = Schema.RequiredMode.REQUIRED) val createdAt: OffsetDateTime,
)
