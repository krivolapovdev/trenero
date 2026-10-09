package org.trenero.backend.lesson.external.spi

import java.time.LocalDate
import java.util.UUID
import org.trenero.backend.common.security.JwtUser
import org.trenero.backend.lesson.external.response.LessonResponse

interface LessonSpi {
  fun getLastGroupLessonsByGroupIds(
    groupIds: List<UUID>,
    jwtUser: JwtUser,
  ): Map<UUID, LessonResponse>

  fun getLessonById(lessonId: UUID, jwtUser: JwtUser): LessonResponse

  fun getLessonsByIds(lessonIds: List<UUID>, jwtUser: JwtUser): Map<UUID, LessonResponse>

  fun getLessonsByGroupId(groupId: UUID, jwtUser: JwtUser): List<LessonResponse>

  fun deleteLesson(lessonId: UUID, jwtUser: JwtUser)

  fun getLessonsByGroupIdAndDateRange(
    groupId: UUID,
    from: LocalDate,
    to: LocalDate,
    jwtUser: JwtUser,
  ): List<LessonResponse>
}
