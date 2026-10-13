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
import org.trenero.backend.lesson.internal.domain.Lesson
import org.trenero.backend.lesson.internal.repository.LessonRepository
import org.trenero.backend.user.internal.repository.UserRepository
import org.trenero.backend.visit.internal.repository.VisitRepository

/**
 * The lookups of the lesson module. Every one of them is scoped to the caller, so a lesson of
 * another account is never returned. The attendance is not part of these lookups; it is read by the
 * visit module.
 */
@DataJpaTest
@Import(TestcontainersConfig::class)
class LessonServiceGetLessonsTest {

  @Autowired private lateinit var lessonRepository: LessonRepository
  @Autowired private lateinit var visitRepository: VisitRepository
  @Autowired private lateinit var userRepository: UserRepository

  private val groupId = UUID.randomUUID()
  private val otherGroupId = UUID.randomUUID()
  private val date = LocalDate.of(2026, 10, 8)

  @Test
  fun returnsTheLessonOfTheCaller() {
    val owner = userRepository.insertOwner()
    val lessonId = insertLesson(owner.id, groupId, date)

    val lesson = service().getLessonById(lessonId, owner)

    assertThat(lesson.id).isEqualTo(lessonId)
    assertThat(lesson.date).isEqualTo(date)
    assertThat(lesson.groupId).isEqualTo(groupId)
    assertThat(lesson.createdAt).isNotNull()
  }

  @Test
  fun rejectsAnUnknownLesson() {
    val owner = userRepository.insertOwner()

    val thrown = catchThrowable { service().getLessonById(UUID.randomUUID(), owner) }

    assertThat(thrown).isInstanceOf(EntityNotFoundException::class.java)
  }

  @Test
  fun hidesTheLessonOfAnotherOwner() {
    val owner = userRepository.insertOwner()
    val stranger = userRepository.insertOwner()
    val foreignLessonId = insertLesson(stranger.id, groupId, date)

    val thrown = catchThrowable { service().getLessonById(foreignLessonId, owner) }

    assertThat(thrown).isInstanceOf(EntityNotFoundException::class.java)
  }

  @Test
  fun mapsTheOwnLessonsByIds() {
    val owner = userRepository.insertOwner()
    val stranger = userRepository.insertOwner()
    val firstId = insertLesson(owner.id, groupId, date)
    val secondId = insertLesson(owner.id, otherGroupId, date.plusDays(7))
    val foreignId = insertLesson(stranger.id, groupId, date)

    val lessons = service().getLessonsByIds(listOf(firstId, secondId, foreignId), owner)

    assertThat(lessons.keys).containsExactlyInAnyOrder(firstId, secondId)
  }

  @Test
  fun returnsAnEmptyMapForNoIds() {
    val owner = userRepository.insertOwner()

    assertThat(service().getLessonsByIds(emptyList(), owner)).isEmpty()
  }

  @Test
  fun returnsTheLessonsOfAGroup() {
    val owner = userRepository.insertOwner()
    val inGroup = insertLesson(owner.id, groupId, date)
    insertLesson(owner.id, otherGroupId, date)
    insertLesson(owner.id, null, date)

    val lessons = service().getLessonsByGroupId(groupId, owner)

    assertThat(lessons.map { it.id }).containsExactly(inGroup)
  }

  @Test
  fun returnsTheLessonsOfARangeWithBothEndsIncluded() {
    val owner = userRepository.insertOwner()
    val first = insertLesson(owner.id, groupId, LocalDate.of(2026, 10, 1))
    val second = insertLesson(owner.id, groupId, LocalDate.of(2026, 10, 31))
    insertLesson(owner.id, groupId, LocalDate.of(2026, 9, 30))
    insertLesson(owner.id, groupId, LocalDate.of(2026, 11, 1))
    insertLesson(owner.id, otherGroupId, LocalDate.of(2026, 10, 15))
    insertLesson(userRepository.insertOwner().id, groupId, LocalDate.of(2026, 10, 15))

    val lessons =
      service()
        .getLessonsByGroupIdAndDateRange(
          groupId,
          LocalDate.of(2026, 10, 1),
          LocalDate.of(2026, 10, 31),
          owner,
        )

    assertThat(lessons.map { it.id }).containsExactly(first, second)
    assertThat(lessons.map { it.date }).isSorted()
  }

  private fun service() = lessonService(lessonRepository, visitRepository)

  private fun insertLesson(ownerId: UUID, groupId: UUID?, date: LocalDate): UUID =
    lessonRepository
      .saveAndFlush(Lesson.builder().ownerId(ownerId).groupId(groupId).date(date).build())
      .id
}
