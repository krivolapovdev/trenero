package org.trenero.backend.group.internal.response

import io.swagger.v3.oas.annotations.media.Schema
import java.util.UUID

/**
 * One row of the monthly group report.
 *
 * [presentDays] lists the 1-based days of the reported month the student was present on. The days
 * of the month the group had a lesson on are listed in `GroupReportResponse.lessonDays`, so a
 * lesson day that is missing from [presentDays] was a lesson the student missed.
 */
data class GroupReportStudentResponse(
  @field:Schema(requiredMode = Schema.RequiredMode.REQUIRED) val studentId: UUID,
  @field:Schema(requiredMode = Schema.RequiredMode.REQUIRED) val fullName: String,
  @field:Schema(requiredMode = Schema.RequiredMode.REQUIRED) val paid: Boolean,
  @field:Schema(requiredMode = Schema.RequiredMode.REQUIRED) val presentDays: List<Int>,
  @field:Schema(requiredMode = Schema.RequiredMode.REQUIRED) val presentCount: Int,
  @field:Schema(requiredMode = Schema.RequiredMode.REQUIRED) val lessonCount: Int,
)
