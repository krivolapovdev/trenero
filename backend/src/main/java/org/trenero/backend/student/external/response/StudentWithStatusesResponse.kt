package org.trenero.backend.student.external.response

import jakarta.validation.constraints.NotNull
import org.trenero.backend.common.domain.StudentStatus

data class StudentWithStatusesResponse(
  @get:NotNull val student: StudentResponse,
  @get:NotNull val statuses: Set<StudentStatus>,
)
