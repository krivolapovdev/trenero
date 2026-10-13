package org.trenero.backend.visit.internal.service

import java.util.UUID
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.data.jpa.test.autoconfigure.DataJpaTest
import org.springframework.context.annotation.Import
import org.trenero.backend.TestcontainersConfig
import org.trenero.backend.common.domain.VisitStatus
import org.trenero.backend.common.domain.VisitType
import org.trenero.backend.user.internal.repository.UserRepository
import org.trenero.backend.visit.internal.mapper.VisitMapperImpl
import org.trenero.backend.visit.internal.repository.VisitRepository

/** The write side of the visit module used when a lesson is created. */
@DataJpaTest
@Import(TestcontainersConfig::class)
class VisitServiceCreateVisitsTest {

  @Autowired private lateinit var visitRepository: VisitRepository
  @Autowired private lateinit var userRepository: UserRepository

  private fun visitService() = VisitService(visitRepository, VisitMapperImpl())

  @Test
  fun storesAVisitForEveryParticipant() {
    val owner = userRepository.insertOwner()
    val annaId = UUID.randomUUID()
    val ivanId = UUID.randomUUID()
    val lessonId = UUID.randomUUID()

    visitService()
      .createVisits(
        lessonId,
        listOf(
          studentVisit(annaId, VisitStatus.PRESENT, VisitType.REGULAR),
          studentVisit(ivanId, VisitStatus.ABSENT, VisitType.FREE),
        ),
        owner,
      )

    val stored = visitRepository.findAllByLessonIdAndOwnerId(lessonId, owner.id)

    assertThat(stored.map { it.studentId }).containsExactlyInAnyOrder(annaId, ivanId)
    assertThat(stored.map { it.ownerId }.toSet()).containsExactly(owner.id)
    assertThat(stored.map { it.lessonId }.toSet()).containsExactly(lessonId)
    assertThat(stored.single { it.studentId == ivanId }.status).isEqualTo(VisitStatus.ABSENT)
    assertThat(stored.single { it.studentId == ivanId }.type).isEqualTo(VisitType.FREE)
  }

  /** A lesson without a single marked student carries no visit row at all. */
  @Test
  fun storesNothingWhenNoParticipantIsSent() {
    val owner = userRepository.insertOwner()
    val lessonId = UUID.randomUUID()

    visitService().createVisits(lessonId, emptyList(), owner)

    assertThat(visitRepository.findAllByLessonIdAndOwnerId(lessonId, owner.id)).isEmpty()
  }
}
