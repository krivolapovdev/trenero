package org.trenero.backend.student.internal.response

import com.fasterxml.jackson.annotation.JsonUnwrapped
import io.swagger.v3.oas.annotations.media.Schema
import org.trenero.backend.common.domain.StudentStatus
import org.trenero.backend.group.external.response.GroupResponse
import org.trenero.backend.student.external.response.StudentResponse

data class StudentSummaryResponse(
  @field:JsonUnwrapped val student: StudentResponse,
  val studentGroup: GroupResponse?,
  @field:Schema(requiredMode = Schema.RequiredMode.REQUIRED) val statuses: Set<StudentStatus>,
)
