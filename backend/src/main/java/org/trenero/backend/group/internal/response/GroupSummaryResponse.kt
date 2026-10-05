package org.trenero.backend.group.internal.response

import com.fasterxml.jackson.annotation.JsonUnwrapped
import org.trenero.backend.group.external.response.GroupResponse

data class GroupSummaryResponse(
  @get:JsonUnwrapped val group: GroupResponse,
  val countOfStudents: Long,
)
