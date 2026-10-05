package org.trenero.backend.student.external.response

import jakarta.validation.constraints.NotNull
import java.time.LocalDate
import java.time.OffsetDateTime
import java.util.UUID

data class StudentResponse(
  @get:NotNull val id: UUID,
  @get:NotNull val fullName: String,
  val birthdate: LocalDate?,
  val phone: String?,
  val note: String?,
  @get:NotNull val createdAt: OffsetDateTime,
)
