package org.trenero.backend.student.internal.service

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
import org.trenero.backend.common.domain.VisitType
import org.trenero.backend.common.security.JwtUser
import org.trenero.backend.student.external.response.StudentResponse
import org.trenero.backend.student.internal.repository.StudentRepository
import org.trenero.backend.student.internal.request.CreateStudentRequest
import org.trenero.backend.user.internal.repository.UserRepository
import org.trenero.backend.visit.internal.domain.Visit
import org.trenero.backend.visit.internal.repository.VisitRepository

/** The deletion behind {@code DELETE /api/v1/students/{studentId}}. */
@DataJpaTest
@Import(TestcontainersConfig::class)
class StudentServiceDeleteStudentTest {

  @Autowired private lateinit var studentRepository: StudentRepository
  @Autowired private lateinit var visitRepository: VisitRepository
  @Autowired private lateinit var userRepository: UserRepository

  @Test
  fun removesTheStudentOfTheCaller() {
    val owner = userRepository.insertOwner()
    val studentId = createStudent(owner, "Ivan Petrov").id

    service().deleteStudent(studentId, owner)

    assertThat(studentRepository.findById(studentId).isPresent).isFalse()
  }

  @Test
  fun keepsTheStudentOfAnotherOwner() {
    val owner = userRepository.insertOwner()
    val stranger = userRepository.insertOwner()
    val studentId = createStudent(owner, "Ivan Petrov").id

    val thrown = catchThrowable { service().deleteStudent(studentId, stranger) }

    assertThat(thrown).isInstanceOf(EntityNotFoundException::class.java)
    assertThat(studentRepository.findById(studentId).isPresent).isTrue()
  }

  @Test
  fun rejectsAnUnknownStudent() {
    val owner = userRepository.insertOwner()

    val thrown = catchThrowable { service().deleteStudent(UUID.randomUUID(), owner) }

    assertThat(thrown).isInstanceOf(EntityNotFoundException::class.java)
  }

  /**
   * Characterisation of a known gap rather than a requirement. The student row is the only row the
   * service removes: no table references `students(id)`, so the visits, the group links and the
   * student payments of the deleted student stay behind. The group summary counts the rows of
   * `group_students`, so the count of a group stays too high after the deletion while the page no
   * longer lists the student.
   */
  @Test
  fun leavesTheVisitsOfTheDeletedStudentBehind() {
    val owner = userRepository.insertOwner()
    val studentId = createStudent(owner, "Ivan Petrov").id
    visitRepository.saveAndFlush(visit(owner.id, studentId))

    service().deleteStudent(studentId, owner)

    assertThat(visitRepository.findAllByStudentIdAndOwnerId(studentId, owner.id)).hasSize(1)
  }

  private fun service() = studentService(studentRepository)

  private fun createStudent(owner: JwtUser, fullName: String): StudentResponse =
    service()
      .createStudent(
        CreateStudentRequest(fullName, LocalDate.of(2010, 5, 1), null, null, false),
        owner,
      )

  private fun visit(ownerId: UUID, studentId: UUID): Visit =
    Visit.builder()
      .ownerId(ownerId)
      .lessonId(UUID.randomUUID())
      .studentId(studentId)
      .status(VisitStatus.PRESENT)
      .type(VisitType.REGULAR)
      .build()
}
