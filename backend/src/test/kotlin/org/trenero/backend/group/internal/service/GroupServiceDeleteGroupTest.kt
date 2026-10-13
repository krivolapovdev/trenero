package org.trenero.backend.group.internal.service

import jakarta.persistence.EntityNotFoundException
import java.util.UUID
import org.assertj.core.api.Assertions.*
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.data.jpa.test.autoconfigure.DataJpaTest
import org.springframework.context.annotation.Import
import org.trenero.backend.TestcontainersConfig
import org.trenero.backend.group.internal.repository.GroupRepository
import org.trenero.backend.group.internal.repository.GroupStudentRepository
import org.trenero.backend.user.internal.repository.UserRepository

/**
 * The deletion behind {@code DELETE /api/v1/groups/{groupId}}.
 *
 * <p>The links to the students of the group are not removed here: a migrated schema cascades them
 * through `fk_group_students_group`, while the schema of this test is built from the entities and
 * therefore has no such key. The lessons of the group and their attendance are not touched at all -
 * see the notes of the module.
 */
@DataJpaTest
@Import(TestcontainersConfig::class)
class GroupServiceDeleteGroupTest {

  @Autowired private lateinit var groupRepository: GroupRepository
  @Autowired private lateinit var groupStudentRepository: GroupStudentRepository
  @Autowired private lateinit var userRepository: UserRepository

  @Test
  fun removesTheGroupOfTheCaller() {
    val owner = userRepository.insertOwner()
    val groupId = service().createGroup(groupRequest("Beginners"), owner).id

    service().deleteGroup(groupId, owner)

    assertThat(groupRepository.findById(groupId).isPresent).isFalse()
  }

  @Test
  fun rejectsAnUnknownGroup() {
    val owner = userRepository.insertOwner()

    val thrown = catchThrowable { service().deleteGroup(UUID.randomUUID(), owner) }

    assertThat(thrown).isInstanceOf(EntityNotFoundException::class.java)
  }

  @Test
  fun hidesTheGroupOfAnotherOwner() {
    val owner = userRepository.insertOwner()
    val stranger = userRepository.insertOwner()
    val foreignGroupId = service().createGroup(groupRequest("Beginners"), stranger).id

    val thrown = catchThrowable { service().deleteGroup(foreignGroupId, owner) }

    assertThat(thrown).isInstanceOf(EntityNotFoundException::class.java)
    assertThat(groupRepository.findById(foreignGroupId).isPresent).isTrue()
  }

  private fun service() = groupService(groupRepository, groupStudentRepository)
}
