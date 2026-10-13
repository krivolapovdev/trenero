package org.trenero.backend.group.internal.service

import java.util.UUID
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
import org.trenero.backend.group.internal.repository.GroupRepository
import org.trenero.backend.group.internal.repository.GroupStudentRepository
import org.trenero.backend.student.external.spi.StudentSpi
import org.trenero.backend.user.internal.repository.UserRepository

/**
 * The creation behind {@code POST /api/v1/groups}. The name of a group is what identifies it on
 * every page, so it is trimmed and it has to stay unique inside the account of the owner; the
 * students that are put into the new group have to exist for the caller.
 */
@DataJpaTest
@Import(TestcontainersConfig::class)
class GroupServiceCreateGroupTest {

  @Autowired private lateinit var groupRepository: GroupRepository
  @Autowired private lateinit var groupStudentRepository: GroupStudentRepository
  @Autowired private lateinit var userRepository: UserRepository

  private val annaId = UUID.randomUUID()
  private val ivanId = UUID.randomUUID()

  @Test
  fun createsTheGroupWithItsStudents() {
    val owner = userRepository.insertOwner()

    val group = service().createGroup(groupRequest("Beginners", annaId, ivanId), owner)

    val stored = groupRepository.findById(group.id).orElseThrow()
    assertThat(stored.ownerId).isEqualTo(owner.id)
    assertThat(stored.name).isEqualTo("Beginners")
    assertThat(stored.defaultPrice).isEqualByComparingTo("1000.00")
    assertThat(stored.note).isEqualTo("note")
    assertThat(groupStudentRepository.findAllByGroupId(group.id, owner.id).map { it.studentId })
      .containsExactlyInAnyOrder(annaId, ivanId)
  }

  @Test
  fun createsAGroupWithoutStudents() {
    val owner = userRepository.insertOwner()

    val group = service().createGroup(groupRequest("Solo"), owner)

    assertThat(groupStudentRepository.findAllByGroupId(group.id, owner.id)).isEmpty()
    assertThat(groupRepository.findById(group.id).isPresent).isTrue()
  }

  @Test
  fun trimsTheNameBeforeStoringIt() {
    val owner = userRepository.insertOwner()

    val group = service().createGroup(groupRequest("  Beginners  "), owner)

    assertThat(group.name).isEqualTo("Beginners")
    assertThat(groupRepository.findById(group.id).orElseThrow().name).isEqualTo("Beginners")
  }

  /**
   * The request record is only checked at the boundary, so the service has to reject blanks too.
   */
  @Test
  fun rejectsABlankName() {
    val owner = userRepository.insertOwner()

    val thrown = catchThrowable { service().createGroup(groupRequest("   "), owner) }

    assertBadRequest(thrown)
    assertThat(groupRepository.findAllByOwnerId(owner.id)).isEmpty()
  }

  @Test
  fun rejectsANameThatIsAlreadyTaken() {
    val owner = userRepository.insertOwner()
    service().createGroup(groupRequest("Beginners"), owner)

    val thrown = catchThrowable { service().createGroup(groupRequest("Beginners"), owner) }

    assertThat(thrown).isInstanceOf(ConflictException::class.java)
    assertThat((thrown as ConflictException).code).isEqualTo(ApiErrorCode.GROUP_NAME_NOT_UNIQUE)
    assertThat(groupRepository.findAllByOwnerId(owner.id)).hasSize(1)
  }

  /** Two names that differ in nothing but surrounding blanks are the same name. */
  @Test
  fun rejectsANameThatDiffersOnlyInSpacing() {
    val owner = userRepository.insertOwner()
    service().createGroup(groupRequest("Beginners"), owner)

    val thrown = catchThrowable { service().createGroup(groupRequest(" Beginners "), owner) }

    assertThat(thrown).isInstanceOf(ConflictException::class.java)
    assertThat(groupRepository.findAllByOwnerId(owner.id)).hasSize(1)
  }

  @Test
  fun keepsTheSameNameOfAnotherOwnerApart() {
    val owner = userRepository.insertOwner()
    val stranger = userRepository.insertOwner()

    service().createGroup(groupRequest("Beginners"), owner)
    service().createGroup(groupRequest("Beginners"), stranger)

    assertThat(groupRepository.count()).isEqualTo(2)
  }

  /**
   * A link to a student that does not exist shows up as a phantom row in the count of the group.
   */
  @Test
  fun rejectsAStudentThatDoesNotExist() {
    val owner = userRepository.insertOwner()

    val thrown = catchThrowable {
      service(noStudentExists()).createGroup(groupRequest("Beginners", annaId), owner)
    }

    assertBadRequest(thrown)
    assertThat(groupRepository.findAllByOwnerId(owner.id)).isEmpty()
    assertThat(groupStudentRepository.findAllByOwnerId(owner.id)).isEmpty()
  }

  private fun service(studentSpi: StudentSpi = allStudentsExist()) =
    groupService(groupRepository, groupStudentRepository, studentSpi)

  private fun assertBadRequest(thrown: Throwable?) {
    assertThat(thrown).isInstanceOf(ResponseStatusException::class.java)
    assertThat((thrown as ResponseStatusException).statusCode).isEqualTo(HttpStatus.BAD_REQUEST)
  }
}
