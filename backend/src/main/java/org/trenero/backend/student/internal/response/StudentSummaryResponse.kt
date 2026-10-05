package org.trenero.backend.student.internal.response

import com.fasterxml.jackson.annotation.JsonUnwrapped
import jakarta.validation.constraints.NotNull
import org.trenero.backend.common.domain.StudentStatus
import org.trenero.backend.group.external.response.GroupResponse
import org.trenero.backend.student.external.response.StudentResponse

data class StudentSummaryResponse(
  @field:JsonUnwrapped val student: StudentResponse,
  val studentGroup: GroupResponse?,
  @field:NotNull val statuses: Set<StudentStatus>,
)
