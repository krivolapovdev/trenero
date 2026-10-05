package org.trenero.backend.common.response

import org.trenero.backend.common.domain.StudentStatus

data class StudentWithStatusesResponse(
  val student: StudentResponse,
  val statuses: Set<StudentStatus>,
)
