package org.trenero.backend.lesson.internal.service

import java.util.UUID
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.data.jpa.test.autoconfigure.DataJpaTest
import org.springframework.context.annotation.Import
import org.trenero.backend.TestDays
import org.trenero.backend.TestcontainersConfig
import org.trenero.backend.common.domain.VisitStatus
import org.trenero.backend.common.domain.VisitType
import org.trenero.backend.lesson.internal.repository.LessonRepository
import org.trenero.backend.user.internal.repository.UserRepository
import org.trenero.backend.visit.internal.repository.VisitRepository

/**
 * The creation behind {@code POST /api/v1/lessons}: a lesson is stored together with the attendance
 * that was marked on the page, and nothing is stored for a student that was left unmarked.
 */
@DataJpaTest
@Import(TestcontainersConfig::class)
class LessonServiceCreateLessonTest {

  @Autowired private lateinit var lessonRepository: LessonRepository
  @Autowired private lateinit var visitRepository: VisitRepository
  @Autowired private lateinit var userRepository: UserRepository

  private val groupId = UUID.randomUUID()
  private val annaId = UUID.randomUUID()
  private val ivanId = UUID.randomUUID()
  private val date = TestDays.day(2026, 10, 8)

  @Test
  fun storesTheLessonWithTheMarkedAttendance() {
    val owner = userRepository.insertOwner()

    val lesson =
      service()
        .createLesson(
          lessonRequest(
            groupId,
            date,
            studentVisit(annaId, VisitStatus.PRESENT, VisitType.REGULAR),
            studentVisit(ivanId, VisitStatus.ABSENT, VisitType.FREE),
          ),
          owner,
        )

    val storedLesson = lessonRepository.findById(lesson.id).orElseThrow()
    assertThat(storedLesson.ownerId).isEqualTo(owner.id)
    assertThat(storedLesson.groupId).isEqualTo(groupId)
    assertThat(storedLesson.date).isEqualTo(date)
    assertThat(storedLesson.createdAt).isNotNull()

    val visits = visitRepository.findAllByLessonIdAndOwnerId(lesson.id, owner.id)
    assertThat(visits.map { it.studentId }).containsExactlyInAnyOrder(annaId, ivanId)
    assertThat(visits.single { it.studentId == ivanId }.status).isEqualTo(VisitStatus.ABSENT)
    assertThat(visits.single { it.studentId == ivanId }.type).isEqualTo(VisitType.FREE)
  }

  @Test
  fun storesAnIndividualLessonWithoutAGroup() {
    val owner = userRepository.insertOwner()

    val lesson =
      service()
        .createLesson(
          lessonRequest(null, date, studentVisit(annaId, VisitStatus.PRESENT)),
          owner,
        )

    assertThat(lesson.groupId).isNull()
    assertThat(lessonRepository.findById(lesson.id).orElseThrow().groupId).isNull()
    assertThat(visitRepository.findAllByLessonIdAndOwnerId(lesson.id, owner.id)).hasSize(1)
  }

  @Test
  fun storesNothingForALessonWithoutMarkedAttendance() {
    val owner = userRepository.insertOwner()

    val lesson = service().createLesson(lessonRequest(groupId, date), owner)

    assertThat(visitRepository.findAllByLessonIdAndOwnerId(lesson.id, owner.id)).isEmpty()
    assertThat(lessonRepository.findById(lesson.id).isPresent).isTrue()
  }

  /** The same student can be marked twice by the page; only the last mark can be stored. */
  @Test
  fun collapsesAStudentThatIsSentTwice() {
    val owner = userRepository.insertOwner()

    val lesson =
      service()
        .createLesson(
          lessonRequest(
            groupId,
            date,
            studentVisit(annaId, VisitStatus.PRESENT),
            studentVisit(annaId, VisitStatus.ABSENT),
          ),
          owner,
        )

    val visits = visitRepository.findAllByLessonIdAndOwnerId(lesson.id, owner.id)

    assertThat(visits).hasSize(1)
    assertThat(visits.single().status).isEqualTo(VisitStatus.ABSENT)
  }

  @Test
  fun keepsTheLessonsOfAnotherOwnerApart() {
    val owner = userRepository.insertOwner()
    val stranger = userRepository.insertOwner()

    service().createLesson(lessonRequest(groupId, date, studentVisit(annaId)), owner)
    service().createLesson(lessonRequest(groupId, date, studentVisit(ivanId)), stranger)

    assertThat(lessonRepository.findAllByGroupIdAndOwnerId(groupId, owner.id)).hasSize(1)
    assertThat(lessonRepository.findAllByGroupIdAndOwnerId(groupId, stranger.id)).hasSize(1)
  }

  private fun service() = lessonService(lessonRepository, visitRepository)
}
