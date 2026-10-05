package org.trenero.backend.group.internal.response

import com.fasterxml.jackson.annotation.JsonUnwrapped
import jakarta.validation.constraints.NotNull
import org.trenero.backend.common.domain.StudentStatus
import org.trenero.backend.student.external.response.StudentResponse

data class GroupStudentSummaryResponse(
  @get:NotNull @get:JsonUnwrapped val student: StudentResponse,
  @get:NotNull val statuses: Set<StudentStatus>,
)
