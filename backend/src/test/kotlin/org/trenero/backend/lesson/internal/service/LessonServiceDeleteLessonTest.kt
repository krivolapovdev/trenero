package org.trenero.backend.lesson.internal.service

import jakarta.persistence.EntityNotFoundException
import java.time.LocalDate
import java.util.UUID
import org.assertj.core.api.Assertions.assertThat
import org.assertj.core.api.Assertions.catchThrowable
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.data.jpa.test.autoconfigure.DataJpaTest
import org.springframework.context.annotation.Import
import org.trenero.backend.TestcontainersConfig
import org.trenero.backend.common.domain.VisitStatus
import org.trenero.backend.common.security.JwtUser
import org.trenero.backend.lesson.internal.repository.LessonRepository
import org.trenero.backend.user.internal.repository.UserRepository
import org.trenero.backend.visit.internal.repository.VisitRepository

/** The deletion behind {@code DELETE /api/v1/lessons/{lessonId}}. */
@DataJpaTest
@Import(TestcontainersConfig::class)
class LessonServiceDeleteLessonTest {

  @Autowired private lateinit var lessonRepository: LessonRepository
  @Autowired private lateinit var visitRepository: VisitRepository
  @Autowired private lateinit var userRepository: UserRepository

  private val groupId = UUID.randomUUID()
  private val annaId = UUID.randomUUID()
  private val date = LocalDate.of(2026, 10, 8)

  @Test
  fun removesTheLessonAndItsAttendance() {
    val owner = userRepository.insertOwner()
    val lessonId = createLesson(owner)

    service().deleteLesson(lessonId, owner)

    assertThat(lessonRepository.findById(lessonId).isPresent).isFalse()
    assertThat(visitRepository.findAllByLessonIdAndOwnerId(lessonId, owner.id)).isEmpty()
  }

  @Test
  fun rejectsAnUnknownLesson() {
    val owner = userRepository.insertOwner()

    val thrown = catchThrowable { service().deleteLesson(UUID.randomUUID(), owner) }

    assertThat(thrown).isInstanceOf(EntityNotFoundException::class.java)
  }

  @Test
  fun hidesTheLessonOfAnotherOwner() {
    val owner = userRepository.insertOwner()
    val stranger = userRepository.insertOwner()
    val foreignLessonId = createLesson(stranger)

    val thrown = catchThrowable { service().deleteLesson(foreignLessonId, owner) }

    assertThat(thrown).isInstanceOf(EntityNotFoundException::class.java)
    assertThat(lessonRepository.findById(foreignLessonId).isPresent).isTrue()
    assertThat(visitRepository.findAllByLessonIdAndOwnerId(foreignLessonId, stranger.id)).hasSize(1)
  }

  private fun service() = lessonService(lessonRepository, visitRepository)

  private fun createLesson(owner: JwtUser): UUID =
    service()
      .createLesson(lessonRequest(groupId, date, studentVisit(annaId, VisitStatus.PRESENT)), owner)
      .id
}
