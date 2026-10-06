package org.trenero.backend.visit.external.spi

import java.util.UUID
import org.trenero.backend.common.domain.StudentVisit
import org.trenero.backend.common.request.CreateVisitRequest
import org.trenero.backend.common.security.JwtUser
import org.trenero.backend.visit.external.response.VisitResponse

interface VisitSpi {
  fun getVisitsByStudentId(studentId: UUID, jwtUser: JwtUser): List<VisitResponse>

  fun getVisitsByStudentIds(
    studentIds: List<UUID>,
    jwtUser: JwtUser,
  ): Map<UUID, List<VisitResponse>>

  fun getVisitsByLessonId(lessonId: UUID, jwtUser: JwtUser): List<VisitResponse>

  fun removeVisitsByLessonId(lessonId: UUID, jwtUser: JwtUser)

  fun updateVisitsByLessonId(
    lessonId: UUID,
    visits: List<StudentVisit>,
    jwtUser: JwtUser,
  )

  fun createVisit(request: CreateVisitRequest, jwtUser: JwtUser): VisitResponse

  fun createVisits(
    lessonId: UUID,
    studentVisitList: List<StudentVisit>,
    jwtUser: JwtUser,
  )
}
