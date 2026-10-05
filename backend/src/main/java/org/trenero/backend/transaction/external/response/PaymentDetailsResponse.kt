package org.trenero.backend.transaction.external.response

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
@JsonSubTypes(JsonSubTypes.Type(value = StudentPaymentDetailsResponse::class, name = "STUDENT"))
sealed interface PaymentDetailsResponse

data class StudentPaymentDetailsResponse(
  @get:NotNull val studentId: UUID,
  @get:NotNull val paidUntil: LocalDate,
  val paidFrom: LocalDate? = null,
  val studentName: String? = null,
) : PaymentDetailsResponse
