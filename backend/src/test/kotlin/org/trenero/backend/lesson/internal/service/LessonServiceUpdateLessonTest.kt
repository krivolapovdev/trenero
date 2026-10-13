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
import org.trenero.backend.lesson.internal.request.UpdateLessonRequest
import org.trenero.backend.user.internal.repository.UserRepository
import org.trenero.backend.visit.internal.repository.VisitRepository

/**
 * The patch behind {@code PATCH /api/v1/lessons/{lessonId}}: the day of the lesson and the
 * attendance of it are replaced. A body without a participant list leaves the attendance alone, an
 * empty one clears it.
 */
@DataJpaTest
@Import(TestcontainersConfig::class)
class LessonServiceUpdateLessonTest {

  @Autowired private lateinit var lessonRepository: LessonRepository
  @Autowired private lateinit var visitRepository: VisitRepository
  @Autowired private lateinit var userRepository: UserRepository

  private val groupId = UUID.randomUUID()
  private val annaId = UUID.randomUUID()
  private val ivanId = UUID.randomUUID()
  private val date = LocalDate.of(2026, 10, 8)

  @Test
  fun patchesTheDayOfTheLesson() {
    val owner = userRepository.insertOwner()
    val lessonId = createLesson(owner)
    val newDate = LocalDate.of(2026, 10, 15)

    val response = service().updateLesson(lessonId, UpdateLessonRequest(newDate, null), owner)

    assertThat(response.date).isEqualTo(newDate)
    assertThat(lessonRepository.findById(lessonId).orElseThrow().date).isEqualTo(newDate)
  }

  @Test
  fun replacesTheAttendanceWithTheSentList() {
    val owner = userRepository.insertOwner()
    val lessonId = createLesson(owner)

    service()
      .updateLesson(
        lessonId,
        UpdateLessonRequest(date, listOf(studentVisit(ivanId, VisitStatus.ABSENT))),
        owner,
      )

    val visits = visitRepository.findAllByLessonIdAndOwnerId(lessonId, owner.id)
    assertThat(visits.map { it.studentId }).containsExactly(ivanId)
    assertThat(visits.single().status).isEqualTo(VisitStatus.ABSENT)
  }

  @Test
  fun keepsTheAttendanceWhenNoParticipantListIsSent() {
    val owner = userRepository.insertOwner()
    val lessonId = createLesson(owner)

    service().updateLesson(lessonId, UpdateLessonRequest(null, null), owner)

    assertThat(visitRepository.findAllByLessonIdAndOwnerId(lessonId, owner.id)).hasSize(1)
  }

  /** Unmarking every student of the lesson leaves the lesson without a single visit. */
  @Test
  fun clearsTheAttendanceForAnEmptyParticipantList() {
    val owner = userRepository.insertOwner()
    val lessonId = createLesson(owner)

    service().updateLesson(lessonId, UpdateLessonRequest(null, emptyList()), owner)

    assertThat(visitRepository.findAllByLessonIdAndOwnerId(lessonId, owner.id)).isEmpty()
  }

  @Test
  fun rejectsAnUnknownLesson() {
    val owner = userRepository.insertOwner()

    val thrown = catchThrowable {
      service().updateLesson(UUID.randomUUID(), UpdateLessonRequest(date, null), owner)
    }

    assertThat(thrown).isInstanceOf(EntityNotFoundException::class.java)
  }

  @Test
  fun hidesTheLessonOfAnotherOwner() {
    val owner = userRepository.insertOwner()
    val stranger = userRepository.insertOwner()
    val foreignLessonId = createLesson(stranger)

    val thrown = catchThrowable {
      service().updateLesson(foreignLessonId, UpdateLessonRequest(date, null), owner)
    }

    assertThat(thrown).isInstanceOf(EntityNotFoundException::class.java)
    assertThat(lessonRepository.findById(foreignLessonId).orElseThrow().date).isEqualTo(date)
  }

  private fun service() = lessonService(lessonRepository, visitRepository)

  private fun createLesson(owner: JwtUser): UUID =
    service()
      .createLesson(lessonRequest(groupId, date, studentVisit(annaId, VisitStatus.PRESENT)), owner)
      .id
}
