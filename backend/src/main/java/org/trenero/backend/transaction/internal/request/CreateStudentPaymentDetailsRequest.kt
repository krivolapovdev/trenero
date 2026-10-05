package org.trenero.backend.transaction.internal.request

import com.fasterxml.jackson.annotation.JsonSubTypes
import com.fasterxml.jackson.annotation.JsonTypeInfo
import jakarta.validation.constraints.NotNull
import java.time.LocalDate
import java.util.UUID

@JsonTypeInfo(
  use = JsonTypeInfo.Id.NAME,
  include = JsonTypeInfo.As.PROPERTY,
  property = "detailsType",
)
@JsonSubTypes(
  JsonSubTypes.Type(value = CreateStudentPaymentDetailsRequest::class, name = "STUDENT")
)
sealed interface CreatePaymentDetailsRequest

data class CreateStudentPaymentDetailsRequest(
  @field:NotNull val studentId: UUID,
  @field:NotNull val paidUntil: LocalDate,
  val paidFrom: LocalDate? = null,
) : CreatePaymentDetailsRequest
