package org.trenero.backend.lesson.internal.service

import jakarta.persistence.EntityNotFoundException
import java.util.UUID
import org.assertj.core.api.Assertions.assertThat
import org.assertj.core.api.Assertions.catchThrowable
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.data.jpa.test.autoconfigure.DataJpaTest
import org.springframework.context.annotation.Import
import org.springframework.test.context.bean.override.mockito.MockitoBean
import org.springframework.transaction.annotation.Propagation
import org.springframework.transaction.annotation.Transactional
import org.trenero.backend.TestDays
import org.trenero.backend.TestcontainersConfig
import org.trenero.backend.common.domain.VisitStatus
import org.trenero.backend.common.domain.VisitType
import org.trenero.backend.lesson.internal.domain.Lesson
import org.trenero.backend.lesson.internal.mapper.LessonMapperImpl
import org.trenero.backend.lesson.internal.repository.LessonRepository
import org.trenero.backend.lesson.internal.request.UpdateLessonRequest
import org.trenero.backend.student.external.spi.StudentSpi
import org.trenero.backend.user.internal.repository.UserRepository
import org.trenero.backend.visit.internal.domain.Visit
import org.trenero.backend.visit.internal.mapper.VisitMapperImpl
import org.trenero.backend.visit.internal.repository.VisitRepository
import org.trenero.backend.visit.internal.service.VisitService

/**
 * The transaction boundaries of the lesson writes, exercised through the Spring proxies (the
 * modules are taken as beans here, not built by hand) and with the test transaction switched off,
 * because a boundary cannot be observed from inside one shared transaction.
 *
 * <p>A lesson write touches two modules: the lesson row and the attendance of it. Both used to be
 * written independently on the delete path, so a request that was rejected afterwards had already
 * changed the data.
 */
@DataJpaTest
@Import(
  TestcontainersConfig::class,
  LessonMapperImpl::class,
  LessonService::class,
  VisitMapperImpl::class,
  VisitService::class,
)
@Transactional(propagation = Propagation.NOT_SUPPORTED)
class LessonServiceWriteTransactionTest {

  @Autowired private lateinit var lessonService: LessonService
  @Autowired private lateinit var lessonRepository: LessonRepository
  @Autowired private lateinit var visitRepository: VisitRepository
  @Autowired private lateinit var userRepository: UserRepository

  @MockitoBean private lateinit var studentSpi: StudentSpi

  private val studentId = UUID.randomUUID()
  private val date = TestDays.day(2026, 10, 8)

  @Test
  fun removesTheLessonAndItsAttendance() {
    val owner = userRepository.insertOwner()
    val lesson = insertLesson(owner.id)
    visitRepository.saveAndFlush(visit(owner.id, lesson.id))

    lessonService.deleteLesson(lesson.id, owner)

    assertThat(lessonRepository.findById(lesson.id).isPresent).isFalse()
    assertThat(visitRepository.findAllByLessonIdAndOwnerId(lesson.id, owner.id)).isEmpty()
  }

  /**
   * The patch writes the attendance first and looks the lesson up afterwards; both are one unit.
   */
  @Test
  fun storesNoAttendanceWhenAnUnknownLessonIsPatched() {
    val owner = userRepository.insertOwner()
    val unknownLessonId = UUID.randomUUID()

    val thrown = catchThrowable {
      lessonService.updateLesson(
        unknownLessonId,
        UpdateLessonRequest(date, listOf(studentVisit(studentId))),
        owner,
      )
    }

    assertThat(thrown).isInstanceOf(EntityNotFoundException::class.java)
    assertThat(visitRepository.findAllByLessonIdAndOwnerId(unknownLessonId, owner.id)).isEmpty()
  }

  /**
   * The removal of the attendance must not outlive the rejected request. The visit belongs to the
   * caller for a lesson of somebody else: nothing ties a visit to the owner of its lesson, and that
   * is exactly the state a half finished delete leaves behind.
   */
  @Test
  fun changesNothingWhenTheLessonCannotBeDeleted() {
    val owner = userRepository.insertOwner()
    val stranger = userRepository.insertOwner()
    val lesson = insertLesson(stranger.id)
    visitRepository.saveAndFlush(visit(owner.id, lesson.id))

    val thrown = catchThrowable { lessonService.deleteLesson(lesson.id, owner) }

    assertThat(thrown).isInstanceOf(EntityNotFoundException::class.java)
    assertThat(visitRepository.findAllByLessonIdAndOwnerId(lesson.id, owner.id)).hasSize(1)
    assertThat(lessonRepository.findById(lesson.id).isPresent).isTrue()
  }

  private fun insertLesson(ownerId: UUID) =
    lessonRepository.saveAndFlush(Lesson.builder().ownerId(ownerId).date(date).build())

  private fun visit(ownerId: UUID, lessonId: UUID) =
    Visit.builder()
      .ownerId(ownerId)
      .lessonId(lessonId)
      .studentId(studentId)
      .status(VisitStatus.PRESENT)
      .type(VisitType.REGULAR)
      .build()
}
