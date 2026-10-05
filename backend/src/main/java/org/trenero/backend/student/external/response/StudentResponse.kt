package org.trenero.backend.student.external.response

import jakarta.validation.constraints.NotNull
import java.time.LocalDate
import java.time.OffsetDateTime
import java.util.UUID

data class StudentResponse(
  @get:NotNull val id: UUID,
  @get:NotNull val fullName: String,
  val birthdate: LocalDate? = null,
  val phone: String? = null,
  val note: String? = null,
  @get:NotNull val createdAt: OffsetDateTime,
)
