package org.trenero.backend.transaction.external.response

import com.fasterxml.jackson.annotation.JsonSubTypes
import com.fasterxml.jackson.annotation.JsonTypeInfo
import io.swagger.v3.oas.annotations.media.Schema
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
  @field:Schema(requiredMode = Schema.RequiredMode.REQUIRED) val studentId: UUID,
  @field:Schema(requiredMode = Schema.RequiredMode.REQUIRED) val paidUntil: LocalDate,
  val paidFrom: LocalDate? = null,
  val studentName: String? = null,
) : PaymentDetailsResponse
