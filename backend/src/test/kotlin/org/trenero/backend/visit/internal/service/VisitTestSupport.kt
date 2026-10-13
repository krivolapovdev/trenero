package org.trenero.backend.visit.internal.service

import java.util.UUID
import org.trenero.backend.common.domain.OAuth2Provider
import org.trenero.backend.common.domain.StudentVisit
import org.trenero.backend.common.domain.VisitStatus
import org.trenero.backend.common.domain.VisitType
import org.trenero.backend.common.security.JwtUser
import org.trenero.backend.user.internal.domain.OAuth2User
import org.trenero.backend.user.internal.repository.UserRepository
import org.trenero.backend.visit.internal.domain.Visit

/**
 * Builds an unsaved visit. The lesson and the student are plain identifiers of the visit module, so
 * they do not have to exist: no lesson or student row is referenced.
 */
internal fun visit(
  ownerId: UUID,
  lessonId: UUID,
  studentId: UUID,
  status: VisitStatus = VisitStatus.PRESENT,
  type: VisitType = VisitType.REGULAR,
): Visit =
  Visit.builder()
    .ownerId(ownerId)
    .lessonId(lessonId)
    .studentId(studentId)
    .status(status)
    .type(type)
    .build()

/** Builds one entry of the participant list that the lesson page sends on create and update. */
internal fun studentVisit(
  studentId: UUID,
  status: VisitStatus = VisitStatus.PRESENT,
  type: VisitType = VisitType.REGULAR,
): StudentVisit = StudentVisit(studentId, status, type)

/**
 * Persists an owner so that the visits of the test satisfy the `fk_visits_owner` foreign key, and
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
