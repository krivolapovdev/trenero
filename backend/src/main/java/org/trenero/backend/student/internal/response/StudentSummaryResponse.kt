package org.trenero.backend.student.internal.response

import com.fasterxml.jackson.annotation.JsonUnwrapped
import jakarta.validation.constraints.NotNull
import org.trenero.backend.common.response.GroupResponse
import org.trenero.backend.common.response.StudentResponse
import org.trenero.backend.student.internal.domain.StudentStatus

data class StudentSummaryResponse(
  @field:JsonUnwrapped val student: StudentResponse,
  val studentGroup: GroupResponse?,
  @field:NotNull val statuses: Set<StudentStatus>,
)
