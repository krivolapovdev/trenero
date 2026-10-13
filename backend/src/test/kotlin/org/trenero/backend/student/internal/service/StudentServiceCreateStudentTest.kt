package org.trenero.backend.student.internal.service

import java.time.LocalDate
import org.assertj.core.api.Assertions.assertThat
import org.assertj.core.api.Assertions.catchThrowable
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.data.jpa.test.autoconfigure.DataJpaTest
import org.springframework.context.annotation.Import
import org.springframework.http.HttpStatus
import org.springframework.web.server.ResponseStatusException
import org.trenero.backend.TestcontainersConfig
import org.trenero.backend.common.exception.ApiErrorCode
import org.trenero.backend.common.exception.ConflictException
import org.trenero.backend.student.internal.repository.StudentRepository
import org.trenero.backend.student.internal.request.CreateStudentRequest
import org.trenero.backend.user.internal.repository.UserRepository

/**
 * The creation behind {@code POST /api/v1/students}. The name of a student is what identifies them
 * on every page, so it is trimmed and it has to be unique inside the account of the owner.
 */
@DataJpaTest
@Import(TestcontainersConfig::class)
class StudentServiceCreateStudentTest {

  @Autowired private lateinit var studentRepository: StudentRepository
  @Autowired private lateinit var userRepository: UserRepository

  private val birthdate = LocalDate.of(2010, 5, 1)

  @Test
  fun createsAStudentOfTheCaller() {
    val owner = userRepository.insertOwner()

    val response = service().createStudent(request("Ivan Petrov"), owner)

    val stored = studentRepository.findById(response.id).orElseThrow()
    assertThat(stored.ownerId).isEqualTo(owner.id)
    assertThat(stored.fullName).isEqualTo("Ivan Petrov")
    assertThat(stored.birthdate).isEqualTo(birthdate)
    assertThat(stored.phone).isEqualTo("+79001234567")
    assertThat(stored.note).isEqualTo("note")
    assertThat(stored.isFree).isFalse()
    assertThat(stored.createdAt).isNotNull()
  }

  @Test
  fun keepsTheSameNameOfAnotherOwnerApart() {
    val owner = userRepository.insertOwner()
    val stranger = userRepository.insertOwner()

    service().createStudent(request("Ivan Petrov"), owner)
    service().createStudent(request("Ivan Petrov"), stranger)

    assertThat(studentRepository.count()).isEqualTo(2)
  }

  @Test
  fun rejectsANameThatIsAlreadyTaken() {
    val owner = userRepository.insertOwner()
    service().createStudent(request("Ivan Petrov"), owner)

    val thrown = catchThrowable { service().createStudent(request("Ivan Petrov"), owner) }

    assertThat(thrown).isInstanceOf(ConflictException::class.java)
    assertThat((thrown as ConflictException).code).isEqualTo(ApiErrorCode.STUDENT_NAME_NOT_UNIQUE)
    assertThat(studentRepository.findAllByOwnerId(owner.id)).hasSize(1)
  }

  @Test
  fun trimsTheNameBeforeStoringIt() {
    val owner = userRepository.insertOwner()

    val response = service().createStudent(request("  Ivan Petrov  "), owner)

    assertThat(response.fullName).isEqualTo("Ivan Petrov")
  }

  /**
   * The name is the only handle a student has, so a name of blanks is no name at all. The request
   * record carries {@code @NotNull} only, which an empty string satisfies.
   */
  @Test
  fun rejectsABlankName() {
    val owner = userRepository.insertOwner()

    val thrown = catchThrowable { service().createStudent(request("   "), owner) }

    assertThat(thrown).isInstanceOf(ResponseStatusException::class.java)
    assertThat((thrown as ResponseStatusException).statusCode).isEqualTo(HttpStatus.BAD_REQUEST)
    assertThat(studentRepository.findAllByOwnerId(owner.id)).isEmpty()
  }

  /** Two names that differ in nothing but surrounding blanks are the same name. */
  @Test
  fun rejectsANameThatDiffersOnlyInSpacing() {
    val owner = userRepository.insertOwner()
    service().createStudent(request("Ivan Petrov"), owner)

    val thrown = catchThrowable { service().createStudent(request("Ivan Petrov "), owner) }

    assertThat(thrown).isInstanceOf(ConflictException::class.java)
    assertThat(studentRepository.findAllByOwnerId(owner.id)).hasSize(1)
  }

  private fun service() = studentService(studentRepository)

  private fun request(
    fullName: String,
    birthdate: LocalDate? = this.birthdate,
    phone: String? = "+79001234567",
    note: String? = "note",
    free: Boolean = false,
  ): CreateStudentRequest = CreateStudentRequest(fullName, birthdate, phone, note, free)
}
