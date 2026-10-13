package org.trenero.backend.visit.internal.service

import java.util.UUID
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.data.jpa.test.autoconfigure.DataJpaTest
import org.springframework.context.annotation.Import
import org.trenero.backend.TestcontainersConfig
import org.trenero.backend.user.internal.repository.UserRepository
import org.trenero.backend.visit.internal.mapper.VisitMapperImpl
import org.trenero.backend.visit.internal.repository.VisitRepository

/** The write side of the visit module used when a lesson is deleted. */
@DataJpaTest
@Import(TestcontainersConfig::class)
class VisitServiceRemoveVisitsByLessonIdTest {

  @Autowired private lateinit var visitRepository: VisitRepository
  @Autowired private lateinit var userRepository: UserRepository

  private fun visitService() = VisitService(visitRepository, VisitMapperImpl())

  @Test
  fun removesOnlyTheVisitsOfTheLesson() {
    val owner = userRepository.insertOwner()
    val lessonId = UUID.randomUUID()
    val otherLessonId = UUID.randomUUID()
    visitRepository.saveAllAndFlush(
      listOf(
        visit(owner.id, lessonId, UUID.randomUUID()),
        visit(owner.id, lessonId, UUID.randomUUID()),
        visit(owner.id, otherLessonId, UUID.randomUUID()),
      )
    )

    visitService().removeVisitsByLessonId(lessonId, owner)

    assertThat(visitRepository.findAllByLessonIdAndOwnerId(lessonId, owner.id)).isEmpty()
    assertThat(visitRepository.findAllByLessonIdAndOwnerId(otherLessonId, owner.id)).hasSize(1)
  }

  @Test
  fun keepsTheVisitsOfAnotherOwner() {
    val owner = userRepository.insertOwner()
    val stranger = userRepository.insertOwner()
    val lessonId = UUID.randomUUID()
    visitRepository.saveAllAndFlush(
      listOf(
        visit(owner.id, lessonId, UUID.randomUUID()),
        visit(stranger.id, lessonId, UUID.randomUUID()),
      )
    )

    visitService().removeVisitsByLessonId(lessonId, owner)

    assertThat(visitRepository.findAllByLessonIdAndOwnerId(lessonId, owner.id)).isEmpty()
    assertThat(visitRepository.findAllByLessonIdAndOwnerId(lessonId, stranger.id)).hasSize(1)
  }
}
