package org.trenero.backend.group.internal.response

import com.fasterxml.jackson.annotation.JsonProperty
import com.fasterxml.jackson.annotation.JsonUnwrapped
import jakarta.validation.constraints.NotNull
import org.trenero.backend.common.response.GroupResponse
import org.trenero.backend.common.response.StudentResponse

data class GroupSummaryResponse(
  @get:NotNull @get:JsonUnwrapped val group: GroupResponse,
  @get:NotNull @get:JsonProperty val groupStudents: List<StudentResponse>,
)
