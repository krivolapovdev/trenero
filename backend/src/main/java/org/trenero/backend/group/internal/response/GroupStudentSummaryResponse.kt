package org.trenero.backend.group.internal.response

import com.fasterxml.jackson.annotation.JsonUnwrapped
import jakarta.validation.constraints.NotNull
import org.trenero.backend.common.domain.StudentStatus
import org.trenero.backend.common.response.StudentResponse

data class GroupStudentSummaryResponse(
  @field:JsonUnwrapped val student: StudentResponse,
  @field:NotNull val statuses: Set<StudentStatus>,
)
