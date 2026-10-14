package org.trenero.backend.student.internal.service

import jakarta.persistence.EntityNotFoundException
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
import org.trenero.backend.common.exception.ConflictException
import org.trenero.backend.common.security.JwtUser
import org.trenero.backend.student.external.response.StudentResponse
import org.trenero.backend.student.internal.repository.StudentRepository
import org.trenero.backend.student.internal.request.CreateStudentRequest
import org.trenero.backend.user.internal.repository.UserRepository

/**
 * The patch behind {@code PATCH /api/v1/students/{studentId}}. The optional fields accept a null to
 * be cleared, while the name is required: it is checked for uniqueness and it can never be left
 * empty, because the name is what identifies the student everywhere.
 */
@DataJpaTest
@Import(TestcontainersConfig::class)
class StudentServiceUpdateStudentTest {

  @Autowired private lateinit var studentRepository: StudentRepository
  @Autowired private lateinit var userRepository: UserRepository

  private val birthdate = LocalDate.of(2010, 5, 1)

  @Test
  fun patchesTheProfileFields() {
    val owner = userRepository.insertOwner()
    val studentId = createStudent(owner, "Ivan Petrov").id
    val newBirthdate = LocalDate.of(2011, 6, 2)

    val response =
      service()
        .updateStudent(
          studentId,
          updates(
            "fullName" to "Ivan Smirnov",
            "birthdate" to newBirthdate.toString(),
            "phone" to "+79990000000",
            "note" to "another note",
            "free" to true,
          ),
          owner,
        )

    assertThat(response.fullName).isEqualTo("Ivan Smirnov")
    assertThat(response.birthdate).isEqualTo(newBirthdate)
    assertThat(response.phone).isEqualTo("+79990000000")
    assertThat(response.note).isEqualTo("another note")
    assertThat(response.free).isTrue()
  }

  @Test
  fun clearsTheOptionalFieldsWithANull() {
    val owner = userRepository.insertOwner()
    val studentId = createStudent(owner, "Ivan Petrov").id

    val response =
      service()
        .updateStudent(
          studentId,
          updates("birthdate" to null, "phone" to null, "note" to null),
          owner,
        )

    assertThat(response.birthdate).isNull()
    assertThat(response.phone).isNull()
    assertThat(response.note).isNull()

    val stored = studentRepository.findById(studentId).orElseThrow()
    assertThat(stored.birthdate).isNull()
    assertThat(stored.phone).isNull()
    assertThat(stored.note).isNull()
  }

  @Test
  fun keepsTheNameWhenThePatchDoesNotCarryOne() {
    val owner = userRepository.insertOwner()
    val studentId = createStudent(owner, "Ivan Petrov").id

    val response = service().updateStudent(studentId, updates("phone" to "+79161111111"), owner)

    assertThat(response.fullName).isEqualTo("Ivan Petrov")
  }

  @Test
  fun trimsThePatchedName() {
    val owner = userRepository.insertOwner()
    val studentId = createStudent(owner, "Ivan Petrov").id

    val response =
      service().updateStudent(studentId, updates("fullName" to "  Ivan Petrov  "), owner)

    assertThat(response.fullName).isEqualTo("Ivan Petrov")
  }

  /** A blank name skips the uniqueness check of the service and lands in a required column. */
  @Test
  fun rejectsABlankPatchedName() {
    val owner = userRepository.insertOwner()
    val studentId = createStudent(owner, "Ivan Petrov").id

    val thrown = catchThrowable {
      service().updateStudent(studentId, updates("fullName" to "   "), owner)
    }

    assertBadRequest(thrown)
    assertThat(studentRepository.findById(studentId).orElseThrow().fullName)
      .isEqualTo("Ivan Petrov")
  }

  @Test
  fun rejectsANullPatchedName() {
    val owner = userRepository.insertOwner()
    val studentId = createStudent(owner, "Ivan Petrov").id

    val thrown = catchThrowable {
      service().updateStudent(studentId, updates("fullName" to null), owner)
    }

    assertBadRequest(thrown)
  }

  @Test
  fun rejectsANameThatIsNotAText() {
    val owner = userRepository.insertOwner()
    val studentId = createStudent(owner, "Ivan Petrov").id

    val thrown = catchThrowable {
      service().updateStudent(studentId, updates("fullName" to 42), owner)
    }

    assertBadRequest(thrown)
  }

  @Test
  fun rejectsTheNameOfAnotherStudent() {
    val owner = userRepository.insertOwner()
    createStudent(owner, "Ivan Petrov")
    val secondStudentId = createStudent(owner, "Anna Petrova").id

    val thrown = catchThrowable {
      service().updateStudent(secondStudentId, updates("fullName" to "Ivan Petrov"), owner)
    }

    assertThat(thrown).isInstanceOf(ConflictException::class.java)
  }

  @Test
  fun acceptsTheOwnNameInAPatch() {
    val owner = userRepository.insertOwner()
    val studentId = createStudent(owner, "Ivan Petrov").id

    val response = service().updateStudent(studentId, updates("fullName" to "Ivan Petrov"), owner)

    assertThat(response.fullName).isEqualTo("Ivan Petrov")
  }

  @Test
  fun hidesTheStudentOfAnotherOwner() {
    val owner = userRepository.insertOwner()
    val stranger = userRepository.insertOwner()
    val foreignStudentId = createStudent(stranger, "Ivan Petrov").id

    val thrown = catchThrowable {
      service().updateStudent(foreignStudentId, updates("phone" to "+79990000000"), owner)
    }

    assertThat(thrown).isInstanceOf(EntityNotFoundException::class.java)
  }

  @Test
  fun rejectsANameExceeding255Characters() {
    val owner = userRepository.insertOwner()
    val studentId = createStudent(owner, "Ivan Petrov").id

    val thrown = catchThrowable {
      service().updateStudent(studentId, updates("fullName" to "a".repeat(256)), owner)
    }

    assertBadRequest(thrown)
  }

  private fun service() = studentService(studentRepository)

  private fun createStudent(owner: JwtUser, fullName: String): StudentResponse =
    service()
      .createStudent(
        CreateStudentRequest(fullName, birthdate, "+79001234567", "note", false),
        owner,
      )

  private fun updates(vararg entries: Pair<String, Any?>): Map<String, Any?> = mapOf(*entries)

  private fun assertBadRequest(thrown: Throwable?) {
    assertThat(thrown).isInstanceOf(ResponseStatusException::class.java)
    assertThat((thrown as ResponseStatusException).statusCode).isEqualTo(HttpStatus.BAD_REQUEST)
  }
}
