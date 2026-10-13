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
import org.trenero.backend.common.security.JwtUser
import org.trenero.backend.user.internal.repository.UserRepository
import org.trenero.backend.visit.internal.mapper.VisitMapperImpl
import org.trenero.backend.visit.internal.repository.VisitRepository

/**
 * The reconciliation used when a lesson is saved: the visits that are stored for the lesson are
 * brought in line with the participants the page sent - an existing participant is patched, a new
 * one is inserted and a participant that is no longer sent is removed.
 */
@DataJpaTest
@Import(TestcontainersConfig::class)
class VisitServiceUpdateVisitsByLessonIdTest {

  @Autowired private lateinit var visitRepository: VisitRepository
  @Autowired private lateinit var userRepository: UserRepository

  private val lessonId = UUID.randomUUID()
  private val otherLessonId = UUID.randomUUID()

  private fun visitService() = VisitService(visitRepository, VisitMapperImpl())

  private fun storedVisits(owner: JwtUser, lesson: UUID = lessonId) =
    visitRepository.findAllByLessonIdAndOwnerId(lesson, owner.id)

  @Test
  fun updatesTheStatusAndTypeOfAnExistingVisit() {
    val owner = userRepository.insertOwner()
    val annaId = UUID.randomUUID()
    visitRepository.saveAndFlush(
      visit(owner.id, lessonId, annaId, VisitStatus.PRESENT, VisitType.REGULAR)
    )

    visitService()
      .updateVisitsByLessonId(
        lessonId,
        listOf(studentVisit(annaId, VisitStatus.EXCUSED, VisitType.FREE)),
        owner,
      )

    val stored = storedVisits(owner)

    assertThat(stored).hasSize(1)
    assertThat(stored.single().status).isEqualTo(VisitStatus.EXCUSED)
    assertThat(stored.single().type).isEqualTo(VisitType.FREE)
  }

  @Test
  fun addsAVisitForAStudentThatIsNewToTheLesson() {
    val owner = userRepository.insertOwner()
    val annaId = UUID.randomUUID()
    val ivanId = UUID.randomUUID()
    visitRepository.saveAndFlush(visit(owner.id, lessonId, annaId))

    visitService()
      .updateVisitsByLessonId(
        lessonId,
        listOf(studentVisit(annaId, VisitStatus.PRESENT), studentVisit(ivanId, VisitStatus.ABSENT)),
        owner,
      )

    val stored = storedVisits(owner)

    assertThat(stored.map { it.studentId }).containsExactlyInAnyOrder(annaId, ivanId)
    assertThat(stored.single { it.studentId == ivanId }.status).isEqualTo(VisitStatus.ABSENT)
    assertThat(stored.map { it.lessonId }.toSet()).containsExactly(lessonId)
  }

  @Test
  fun removesTheVisitOfAStudentThatIsNoLongerSent() {
    val owner = userRepository.insertOwner()
    val annaId = UUID.randomUUID()
    val ivanId = UUID.randomUUID()
    visitRepository.saveAllAndFlush(
      listOf(visit(owner.id, lessonId, annaId), visit(owner.id, lessonId, ivanId))
    )

    visitService()
      .updateVisitsByLessonId(lessonId, listOf(studentVisit(ivanId, VisitStatus.ABSENT)), owner)

    val stored = storedVisits(owner)

    assertThat(stored.map { it.studentId }).containsExactly(ivanId)
  }

  @Test
  fun reconcilesTheAddedTheUpdatedAndTheRemovedStudents() {
    val owner = userRepository.insertOwner()
    val annaId = UUID.randomUUID()
    val ivanId = UUID.randomUUID()
    val peterId = UUID.randomUUID()
    visitRepository.saveAllAndFlush(
      listOf(
        visit(owner.id, lessonId, annaId, VisitStatus.PRESENT),
        visit(owner.id, lessonId, ivanId, VisitStatus.ABSENT),
      )
    )

    visitService()
      .updateVisitsByLessonId(
        lessonId,
        listOf(
          studentVisit(ivanId, VisitStatus.EXCUSED, VisitType.FREE),
          studentVisit(peterId, VisitStatus.PRESENT),
        ),
        owner,
      )

    val stored = storedVisits(owner)

    assertThat(stored.map { it.studentId }).containsExactlyInAnyOrder(ivanId, peterId)
    assertThat(stored.single { it.studentId == ivanId }.status).isEqualTo(VisitStatus.EXCUSED)
    assertThat(stored.single { it.studentId == ivanId }.type).isEqualTo(VisitType.FREE)
  }

  /**
   * The page can send the same student more than once. Only one visit may be stored for a student
   * and a lesson - the {@code idx_visits_owner_lesson_student_unique} index of the schema enforces
   * that -, and the last entry has to win, exactly like the participant list of a new lesson is
   * collapsed. Today the update inserts a second row for the student, which the unique index
   * rejects on a migrated schema.
   */
  @Test
  fun storesASingleVisitWhenAStudentIsSentTwice() {
    val owner = userRepository.insertOwner()
    val ivanId = UUID.randomUUID()

    visitService()
      .updateVisitsByLessonId(
        lessonId,
        listOf(
          studentVisit(ivanId, VisitStatus.PRESENT),
          studentVisit(ivanId, VisitStatus.EXCUSED),
        ),
        owner,
      )

    val stored = storedVisits(owner)

    assertThat(stored).hasSize(1)
    assertThat(stored.single().status).isEqualTo(VisitStatus.EXCUSED)
  }

  @Test
  fun doesNotTouchTheVisitsOfAnotherLesson() {
    val owner = userRepository.insertOwner()
    val annaId = UUID.randomUUID()
    visitRepository.saveAndFlush(visit(owner.id, otherLessonId, annaId))

    visitService().updateVisitsByLessonId(lessonId, listOf(studentVisit(UUID.randomUUID())), owner)

    assertThat(storedVisits(owner, otherLessonId).map { it.studentId }).containsExactly(annaId)
  }

  @Test
  fun keepsTheVisitsOfAnotherOwner() {
    val owner = userRepository.insertOwner()
    val stranger = userRepository.insertOwner()
    val annaId = UUID.randomUUID()
    visitRepository.saveAndFlush(visit(stranger.id, lessonId, annaId))

    visitService().updateVisitsByLessonId(lessonId, emptyList(), owner)

    assertThat(visitRepository.findAllByLessonIdAndOwnerId(lessonId, stranger.id)).hasSize(1)
  }
}
