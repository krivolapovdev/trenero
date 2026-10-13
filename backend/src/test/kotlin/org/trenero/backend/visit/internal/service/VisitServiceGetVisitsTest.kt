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

/**
 * Read side of the visit module: the per lesson, per student and grouped lookups that the lesson
 * page, the student page and the group report are built from.
 *
 * <p>Every lookup is scoped to the owner of the caller, so a visit that was stored by another
 * account must never be returned.
 */
@DataJpaTest
@Import(TestcontainersConfig::class)
class VisitServiceGetVisitsTest {

  @Autowired private lateinit var visitRepository: VisitRepository
  @Autowired private lateinit var userRepository: UserRepository

  private val annaId = UUID.randomUUID()
  private val ivanId = UUID.randomUUID()
  private val peterId = UUID.randomUUID()
  private val lessonId = UUID.randomUUID()
  private val otherLessonId = UUID.randomUUID()

  private fun visitService() = VisitService(visitRepository, VisitMapperImpl())

  @Test
  fun mapsTheVisitsOfALesson() {
    val owner = userRepository.insertOwner()
    visitRepository.saveAllAndFlush(
      listOf(
        visit(owner.id, lessonId, annaId, VisitStatus.PRESENT, VisitType.REGULAR),
        visit(owner.id, lessonId, ivanId, VisitStatus.ABSENT, VisitType.FREE),
      )
    )

    val visits = visitService().getVisitsByLessonId(lessonId, owner)

    assertThat(visits.map { it.studentId }).containsExactlyInAnyOrder(annaId, ivanId)
    assertThat(visits.map { it.lessonId }.toSet()).containsExactly(lessonId)
    assertThat(visits.map { it.id }.toSet()).hasSize(2)
    assertThat(visits.single { it.studentId == ivanId }.status).isEqualTo(VisitStatus.ABSENT)
    assertThat(visits.single { it.studentId == ivanId }.type).isEqualTo(VisitType.FREE)
  }

  @Test
  fun returnsNoVisitsForALessonWithoutAny() {
    val owner = userRepository.insertOwner()

    assertThat(visitService().getVisitsByLessonId(lessonId, owner)).isEmpty()
  }

  @Test
  fun hidesTheVisitsOfAnotherOwner() {
    val owner = userRepository.insertOwner()
    val stranger = userRepository.insertOwner()
    visitRepository.saveAndFlush(visit(stranger.id, lessonId, annaId))

    assertThat(visitService().getVisitsByLessonId(lessonId, owner)).isEmpty()
  }

  @Test
  fun returnsTheVisitsOfEveryRequestedLesson() {
    val owner = userRepository.insertOwner()
    val outOfScopeLessonId = UUID.randomUUID()
    visitRepository.saveAllAndFlush(
      listOf(
        visit(owner.id, lessonId, annaId),
        visit(owner.id, otherLessonId, ivanId),
        visit(owner.id, outOfScopeLessonId, peterId),
      )
    )

    val visits = visitService().getVisitsByLessonIds(listOf(lessonId, otherLessonId), owner)

    assertThat(visits.map { it.studentId }).containsExactlyInAnyOrder(annaId, ivanId)
  }

  @Test
  fun returnsNoVisitsForAnEmptyLessonIdList() {
    val owner = userRepository.insertOwner()
    visitRepository.saveAndFlush(visit(owner.id, lessonId, annaId))

    assertThat(visitService().getVisitsByLessonIds(emptyList(), owner)).isEmpty()
  }

  @Test
  fun returnsEveryVisitOfAStudent() {
    val owner = userRepository.insertOwner()
    visitRepository.saveAllAndFlush(
      listOf(
        visit(owner.id, lessonId, annaId),
        visit(owner.id, otherLessonId, annaId),
        visit(owner.id, lessonId, ivanId),
      )
    )

    val visits = visitService().getVisitsByStudentId(annaId, owner)

    assertThat(visits.map { it.lessonId }).containsExactlyInAnyOrder(lessonId, otherLessonId)
  }

  @Test
  fun returnsNoVisitsForAStudentWithoutAny() {
    val owner = userRepository.insertOwner()

    assertThat(visitService().getVisitsByStudentId(annaId, owner)).isEmpty()
  }

  @Test
  fun groupsTheVisitsOfEveryRequestedStudent() {
    val owner = userRepository.insertOwner()
    visitRepository.saveAllAndFlush(
      listOf(
        visit(owner.id, lessonId, annaId),
        visit(owner.id, otherLessonId, annaId),
        visit(owner.id, lessonId, ivanId),
      )
    )

    val visits = visitService().getVisitsByStudentIds(listOf(annaId, ivanId, peterId), owner)

    assertThat(visits.keys).containsExactlyInAnyOrder(annaId, ivanId)
    assertThat(visits.getValue(annaId).map { it.lessonId })
      .containsExactlyInAnyOrder(lessonId, otherLessonId)
    assertThat(visits.getValue(ivanId).map { it.lessonId }).containsExactly(lessonId)
  }

  /**
   * The map is sparse by contract: a requested student without a visit carries no entry, and the
   * callers fall back to an empty list through {@code getOrDefault}. A student must therefore not
   * be reported with an empty list here, which would otherwise hide a missing group link.
   */
  @Test
  fun leavesOutARequestedStudentWithoutVisits() {
    val owner = userRepository.insertOwner()
    visitRepository.saveAndFlush(visit(owner.id, lessonId, annaId))

    val visits = visitService().getVisitsByStudentIds(listOf(annaId, peterId), owner)

    assertThat(visits).containsOnlyKeys(annaId)
  }

  @Test
  fun hidesTheGroupedVisitsOfAnotherOwner() {
    val owner = userRepository.insertOwner()
    val stranger = userRepository.insertOwner()
    visitRepository.saveAndFlush(visit(stranger.id, lessonId, annaId))

    assertThat(visitService().getVisitsByStudentIds(listOf(annaId), owner)).isEmpty()
  }
}
