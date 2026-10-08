package org.trenero.backend.group.internal.response

import io.swagger.v3.oas.annotations.media.Schema
import java.util.UUID

/**
 * Monthly attendance report of a group.
 *
 * [lessonDays] lists the 1-based days of the month the group had a lesson on, which are the days
 * the report renders a mark for. [totalPresent] and [totalLessons] are the sums of the per student
 * results, so they can be rendered as the final `450/540` cell of the report table.
 */
data class GroupReportResponse(
  @field:Schema(requiredMode = Schema.RequiredMode.REQUIRED) val groupId: UUID,
  @field:Schema(requiredMode = Schema.RequiredMode.REQUIRED) val groupName: String,
  @field:Schema(requiredMode = Schema.RequiredMode.REQUIRED) val year: Int,
  @field:Schema(requiredMode = Schema.RequiredMode.REQUIRED) val month: Int,
  @field:Schema(requiredMode = Schema.RequiredMode.REQUIRED) val dayCount: Int,
  @field:Schema(requiredMode = Schema.RequiredMode.REQUIRED) val lessonDays: List<Int>,
  @field:Schema(requiredMode = Schema.RequiredMode.REQUIRED)
  val students: List<GroupReportStudentResponse>,
  @field:Schema(requiredMode = Schema.RequiredMode.REQUIRED) val totalPresent: Int,
  @field:Schema(requiredMode = Schema.RequiredMode.REQUIRED) val totalLessons: Int,
)
