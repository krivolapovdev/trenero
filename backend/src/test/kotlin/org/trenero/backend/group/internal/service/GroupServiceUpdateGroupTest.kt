package org.trenero.backend.group.internal.service

import jakarta.persistence.EntityNotFoundException
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
import org.trenero.backend.common.exception.ConflictException
import org.trenero.backend.common.security.JwtUser
import org.trenero.backend.group.internal.repository.GroupRepository
import org.trenero.backend.group.internal.repository.GroupStudentRepository
import org.trenero.backend.student.external.spi.StudentSpi
import org.trenero.backend.user.internal.repository.UserRepository

/**
 * The patch behind {@code PATCH /api/v1/groups/{groupId}}: the name, the price, the note and the
 * students of the group. The name is required and unique, so a patch may not leave it empty and may
 * not take a name another group already carries.
 */
@DataJpaTest
@Import(TestcontainersConfig::class)
class GroupServiceUpdateGroupTest {

  @Autowired private lateinit var groupRepository: GroupRepository
  @Autowired private lateinit var groupStudentRepository: GroupStudentRepository
  @Autowired private lateinit var userRepository: UserRepository

  private val annaId = UUID.randomUUID()
  private val ivanId = UUID.randomUUID()

  @Test
  fun patchesTheNameThePriceAndTheNote() {
    val owner = userRepository.insertOwner()
    val groupId = createGroup(owner, "Beginners")

    val response =
      service()
        .updateGroup(
          groupId,
          updates("name" to "Advanced", "defaultPrice" to "2500.00", "note" to "evening"),
          owner,
        )

    assertThat(response.name).isEqualTo("Advanced")
    val stored = groupRepository.findById(groupId).orElseThrow()
    assertThat(stored.name).isEqualTo("Advanced")
    assertThat(stored.defaultPrice).isEqualByComparingTo("2500.00")
    assertThat(stored.note).isEqualTo("evening")
  }

  @Test
  fun trimsThePatchedName() {
    val owner = userRepository.insertOwner()
    val groupId = createGroup(owner, "Beginners")

    val response = service().updateGroup(groupId, updates("name" to "  Advanced  "), owner)

    assertThat(response.name).isEqualTo("Advanced")
  }

  @Test
  fun keepsTheNameWhenThePatchDoesNotCarryOne() {
    val owner = userRepository.insertOwner()
    val groupId = createGroup(owner, "Beginners")

    val response = service().updateGroup(groupId, updates("note" to "evening"), owner)

    assertThat(response.name).isEqualTo("Beginners")
  }

  @Test
  fun rejectsABlankPatchedName() {
    val owner = userRepository.insertOwner()
    val groupId = createGroup(owner, "Beginners")

    val thrown = catchThrowable { service().updateGroup(groupId, updates("name" to "   "), owner) }

    assertBadRequest(thrown)
    assertThat(groupRepository.findById(groupId).orElseThrow().name).isEqualTo("Beginners")
  }

  @Test
  fun rejectsANullPatchedName() {
    val owner = userRepository.insertOwner()
    val groupId = createGroup(owner, "Beginners")

    val thrown = catchThrowable { service().updateGroup(groupId, updates("name" to null), owner) }

    assertBadRequest(thrown)
  }

  @Test
  fun rejectsANameThatIsNotAText() {
    val owner = userRepository.insertOwner()
    val groupId = createGroup(owner, "Beginners")

    val thrown = catchThrowable { service().updateGroup(groupId, updates("name" to 42), owner) }

    assertBadRequest(thrown)
  }

  @Test
  fun rejectsTheNameOfAnotherGroup() {
    val owner = userRepository.insertOwner()
    createGroup(owner, "Beginners")
    val secondGroupId = createGroup(owner, "Advanced")

    val thrown = catchThrowable {
      service().updateGroup(secondGroupId, updates("name" to "Beginners"), owner)
    }

    assertThat(thrown).isInstanceOf(ConflictException::class.java)
  }

  @Test
  fun acceptsTheOwnNameInAPatch() {
    val owner = userRepository.insertOwner()
    val groupId = createGroup(owner, "Beginners")

    val response = service().updateGroup(groupId, updates("name" to "Beginners"), owner)

    assertThat(response.name).isEqualTo("Beginners")
  }

  @Test
  fun addsTheStudentsOfTheRequest() {
    val owner = userRepository.insertOwner()
    val groupId = createGroup(owner, "Beginners", annaId)

    service().updateGroup(groupId, updates("studentIds" to listOf(annaId, ivanId)), owner)

    assertThat(groupStudentRepository.findAllByGroupId(groupId, owner.id).map { it.studentId })
      .containsExactlyInAnyOrder(annaId, ivanId)
  }

  @Test
  fun rejectsAnUnknownStudentInTheRequest() {
    val owner = userRepository.insertOwner()
    val groupId = createGroup(owner, "Beginners", annaId)

    val thrown = catchThrowable {
      service(noStudentExists())
        .updateGroup(groupId, updates("studentIds" to listOf(ivanId)), owner)
    }

    assertBadRequest(thrown)
    assertThat(groupStudentRepository.findAllByGroupId(groupId, owner.id).map { it.studentId })
      .containsExactly(annaId)
  }

  @Test
  fun hidesTheGroupOfAnotherOwner() {
    val owner = userRepository.insertOwner()
    val stranger = userRepository.insertOwner()
    val foreignGroupId = createGroup(stranger, "Beginners")

    val thrown = catchThrowable {
      service().updateGroup(foreignGroupId, updates("name" to "Hacked"), owner)
    }

    assertThat(thrown).isInstanceOf(EntityNotFoundException::class.java)
    assertThat(groupRepository.findById(foreignGroupId).orElseThrow().name).isEqualTo("Beginners")
  }

  private fun service(studentSpi: StudentSpi = allStudentsExist()) =
    groupService(groupRepository, groupStudentRepository, studentSpi)

  private fun createGroup(owner: JwtUser, name: String, vararg studentIds: UUID): UUID =
    service().createGroup(groupRequest(name, *studentIds), owner).id

  private fun updates(vararg entries: Pair<String, Any?>): Map<String, Any?> = mapOf(*entries)

  private fun assertBadRequest(thrown: Throwable?) {
    assertThat(thrown).isInstanceOf(ResponseStatusException::class.java)
    assertThat((thrown as ResponseStatusException).statusCode).isEqualTo(HttpStatus.BAD_REQUEST)
  }
}
