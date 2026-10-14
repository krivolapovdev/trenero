package org.trenero.backend.lesson.internal.service

import java.time.OffsetDateTime
import java.util.UUID
import org.mockito.Mockito.mock
import org.trenero.backend.common.domain.OAuth2Provider
import org.trenero.backend.common.domain.StudentVisit
import org.trenero.backend.common.domain.VisitStatus
import org.trenero.backend.common.domain.VisitType
import org.trenero.backend.common.security.JwtUser
import org.trenero.backend.lesson.internal.mapper.LessonMapperImpl
import org.trenero.backend.lesson.internal.repository.LessonRepository
import org.trenero.backend.lesson.internal.request.CreateLessonRequest
import org.trenero.backend.student.external.spi.StudentSpi
import org.trenero.backend.user.internal.domain.OAuth2User
import org.trenero.backend.user.internal.repository.UserRepository
import org.trenero.backend.visit.internal.mapper.VisitMapperImpl
import org.trenero.backend.visit.internal.repository.VisitRepository
import org.trenero.backend.visit.internal.service.VisitService

/**
 * Builds the service under test together with the *real* visit module: the attendance a lesson
 * writes is thereby really stored and can be asserted on, instead of being checked through a mock.
 * The student SPI is only asked for names by the details lookup and `self` is only used by it, so
 * both stay empty.
 */
internal fun lessonService(
  lessonRepository: LessonRepository,
  visitRepository: VisitRepository,
): LessonService =
  LessonService(
    lessonRepository,
    LessonMapperImpl(),
    null,
    VisitService(visitRepository, VisitMapperImpl()),
    mock(StudentSpi::class.java),
  )

internal fun lessonRequest(
  groupId: UUID?,
  date: OffsetDateTime,
  vararg students: StudentVisit,
): CreateLessonRequest = CreateLessonRequest(groupId, date, students.toList())

internal fun studentVisit(
  studentId: UUID,
  status: VisitStatus = VisitStatus.PRESENT,
  type: VisitType = VisitType.REGULAR,
): StudentVisit = StudentVisit(studentId, status, type)

/**
 * Persists an owner so that the lessons of the test satisfy the `fk_lessons_owner` foreign key, and
 * returns the principal the service is called with.
 */
internal fun UserRepository.insertOwner(): JwtUser {
  val owner =
    saveAndFlush(
      OAuth2User.builder()
        .provider(OAuth2Provider.GOOGLE)
        .providerId(UUID.randomUUID().toString())
        .email(UUID.randomUUID().toString() + "@example.com")
        .build()
    )

  return JwtUser(owner.id, owner.email)
}
