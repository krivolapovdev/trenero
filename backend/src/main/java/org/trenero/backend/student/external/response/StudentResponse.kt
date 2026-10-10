package org.trenero.backend.student.external.response

import io.swagger.v3.oas.annotations.media.Schema
import java.time.LocalDate
import java.time.OffsetDateTime
import java.util.UUID

data class StudentResponse(
  @field:Schema(requiredMode = Schema.RequiredMode.REQUIRED) val id: UUID,
  @field:Schema(requiredMode = Schema.RequiredMode.REQUIRED) val fullName: String,
  val birthdate: LocalDate? = null,
  val phone: String? = null,
  val note: String? = null,
  @field:Schema(requiredMode = Schema.RequiredMode.REQUIRED) val createdAt: OffsetDateTime,
  @field:Schema(requiredMode = Schema.RequiredMode.REQUIRED) val free: Boolean,
)
