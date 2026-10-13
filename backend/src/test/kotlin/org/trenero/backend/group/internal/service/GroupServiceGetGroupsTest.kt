package org.trenero.backend.group.internal.service

import jakarta.persistence.EntityNotFoundException
import java.util.UUID
import org.assertj.core.api.Assertions.assertThat
import org.assertj.core.api.Assertions.catchThrowable
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.data.jpa.test.autoconfigure.DataJpaTest
import org.springframework.context.annotation.Import
import org.trenero.backend.TestcontainersConfig
import org.trenero.backend.common.security.JwtUser
import org.trenero.backend.group.internal.repository.GroupRepository
import org.trenero.backend.group.internal.repository.GroupStudentRepository
import org.trenero.backend.user.internal.repository.UserRepository

/** The group lookups of the group page and of the pages of the other modules. */
@DataJpaTest
@Import(TestcontainersConfig::class)
class GroupServiceGetGroupsTest {

  @Autowired private lateinit var groupRepository: GroupRepository
  @Autowired private lateinit var groupStudentRepository: GroupStudentRepository
  @Autowired private lateinit var userRepository: UserRepository

  private val annaId = UUID.randomUUID()
  private val ivanId = UUID.randomUUID()

  @Test
  fun returnsTheGroupOfTheCaller() {
    val owner = userRepository.insertOwner()
    val groupId = createGroup(owner, "Beginners", annaId)

    val group = service().getGroupById(groupId, owner)

    assertThat(group.id).isEqualTo(groupId)
    assertThat(group.name).isEqualTo("Beginners")
    assertThat(group.createdAt).isNotNull()
  }

  @Test
  fun rejectsAnUnknownGroup() {
    val owner = userRepository.insertOwner()

    val thrown = catchThrowable { service().getGroupById(UUID.randomUUID(), owner) }

    assertThat(thrown).isInstanceOf(EntityNotFoundException::class.java)
  }

  @Test
  fun hidesTheGroupOfAnotherOwner() {
    val owner = userRepository.insertOwner()
    val stranger = userRepository.insertOwner()
    val foreignGroupId = createGroup(stranger, "Beginners")

    val thrown = catchThrowable { service().getGroupById(foreignGroupId, owner) }

    assertThat(thrown).isInstanceOf(EntityNotFoundException::class.java)
  }

  @Test
  fun mapsTheOwnGroupsByIds() {
    val owner = userRepository.insertOwner()
    val stranger = userRepository.insertOwner()
    val firstId = createGroup(owner, "Beginners")
    val secondId = createGroup(owner, "Advanced")
    val foreignId = createGroup(stranger, "Advanced")

    val groups = service().getGroupsByIds(listOf(firstId, secondId, foreignId), owner)

    assertThat(groups.keys).containsExactlyInAnyOrder(firstId, secondId)
  }

  @Test
  fun returnsAnEmptyMapForNoIds() {
    val owner = userRepository.insertOwner()

    assertThat(service().getGroupsByIds(emptyList(), owner)).isEmpty()
  }

  @Test
  fun countsTheStudentsOfEveryGroup() {
    val owner = userRepository.insertOwner()
    createGroup(owner, "Beginners", annaId, ivanId)
    createGroup(owner, "Solo")

    val summary = service().getAllGroupsSummary(owner)

    assertThat(summary.map { it.group.name }).containsExactly("Beginners", "Solo")
    assertThat(summary.map { it.countOfStudents }).containsExactly(2L, 0L)
  }

  @Test
  fun countsNothingForAnOwnerWithoutGroups() {
    val owner = userRepository.insertOwner()

    assertThat(service().getAllGroupsSummary(owner)).isEmpty()
  }

  @Test
  fun keepsTheGroupsOfAnotherOwnerOut() {
    val owner = userRepository.insertOwner()
    val stranger = userRepository.insertOwner()
    createGroup(owner, "Beginners", annaId)
    createGroup(stranger, "Advanced", ivanId)

    val summary = service().getAllGroupsSummary(owner)

    assertThat(summary.map { it.group.name }).containsExactly("Beginners")
    assertThat(summary.single().countOfStudents).isEqualTo(1L)
  }

  private fun service() = groupService(groupRepository, groupStudentRepository)

  private fun createGroup(owner: JwtUser, name: String, vararg studentIds: UUID): UUID =
    service().createGroup(groupRequest(name, *studentIds), owner).id
}
