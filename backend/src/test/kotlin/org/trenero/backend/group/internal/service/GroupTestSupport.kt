package org.trenero.backend.group.internal.service

import java.math.BigDecimal
import java.time.OffsetDateTime
import java.time.ZoneOffset
import java.util.UUID
import org.mockito.Mockito
import org.mockito.Mockito.mock
import org.trenero.backend.common.domain.OAuth2Provider
import org.trenero.backend.common.security.JwtUser
import org.trenero.backend.group.external.response.GroupResponse
import org.trenero.backend.group.internal.domain.Group
import org.trenero.backend.group.internal.domain.GroupStudent
import org.trenero.backend.group.internal.mapper.GroupMapperImpl
import org.trenero.backend.group.internal.mapper.GroupStudentMapperImpl
import org.trenero.backend.group.internal.repository.GroupRepository
import org.trenero.backend.group.internal.repository.GroupStudentRepository
import org.trenero.backend.group.internal.request.CreateGroupRequest
import org.trenero.backend.student.external.response.StudentResponse
import org.trenero.backend.student.external.response.StudentWithStatusesResponse
import org.trenero.backend.student.external.spi.StudentSpi
import org.trenero.backend.user.internal.domain.OAuth2User
import org.trenero.backend.user.internal.repository.UserRepository

internal val CREATED_AT: OffsetDateTime =
  OffsetDateTime.of(2026, 10, 8, 12, 0, 0, 0, ZoneOffset.UTC)

/**
 * Builds the group service on the real repositories and mappers. The group writes run through the
 * `self` reference of the service, so that reference is stubbed onto the repository; the student
 * SPI is answered by the given double, every other module stays empty because the operations under
 * test do not use them.
 */
internal fun groupService(
  groupRepository: GroupRepository,
  groupStudentRepository: GroupStudentRepository,
  studentSpi: StudentSpi = allStudentsExist(),
): GroupService {
  val self = mock(GroupService::class.java)
  Mockito.`when`(self.saveGroup(Mockito.any<Group>())).thenAnswer { invocation ->
    groupRepository.saveAndFlush(invocation.getArgument(0))
  }

  return GroupService(
    groupRepository,
    GroupMapperImpl(),
    GroupReportService(),
    groupStudentServiceOn(groupStudentRepository),
    null,
    studentSpi,
    null,
    null,
    self,
  )
}

private fun groupStudentServiceOn(
  groupStudentRepository: GroupStudentRepository
): GroupStudentService {
  // The link service asks the group service for the group before it writes; the group itself is not
  // under test here, so the answer is a plain existing group.
  val groupService = mock(GroupService::class.java)
  Mockito.`when`(groupService.getGroupById(Mockito.any(), Mockito.any()))
    .thenReturn(groupResponse(UUID.randomUUID(), "Group"))

  val self = mock(GroupStudentService::class.java)
  Mockito.`when`(self.saveGroupStudent(Mockito.any<GroupStudent>())).thenAnswer { invocation ->
    groupStudentRepository.saveAndFlush(invocation.getArgument(0))
  }

  return GroupStudentService(groupStudentRepository, GroupStudentMapperImpl(), groupService, self)
}

/** A student SPI that reports every requested student as an existing student of the caller. */
internal fun allStudentsExist(): StudentSpi = FakeStudentSpi(existingStudentIds = null)

/** Knows no student at all, the way the lookup of a foreign or gone student answers. */
internal fun noStudentExists(): StudentSpi = FakeStudentSpi(existingStudentIds = emptySet())

/**
 * A hand written double, because the SPI is a Kotlin interface: throwing a Mockito matcher that is
 * null at a non-null parameter of it fails the null check of the call itself.
 *
 * @param existingStudentIds the students the double knows, or `null` to accept every id.
 */
internal class FakeStudentSpi(private val existingStudentIds: Set<UUID>?) : StudentSpi {

  var lastRequestedIds: List<UUID> = emptyList()
    private set

  override fun getAllStudents(jwtUser: JwtUser): List<StudentResponse> = emptyList()

  override fun getStudentById(studentId: UUID, jwtUser: JwtUser): StudentResponse =
    student(studentId)

  override fun getStudentsByIds(
    studentIds: List<UUID>,
    jwtUser: JwtUser,
  ): Map<UUID, StudentResponse> {
    lastRequestedIds = studentIds

    return studentIds.filter { known(it) }.associateWith { student(it) }
  }

  override fun getStudentsWithStatusesByIds(
    studentIds: List<UUID>,
    jwtUser: JwtUser,
  ): Map<UUID, StudentWithStatusesResponse> = emptyMap()

  override fun getStudentsWithStatusesByGroupId(
    studentIds: List<UUID>,
    groupId: UUID,
    jwtUser: JwtUser,
  ): Map<UUID, StudentWithStatusesResponse> = emptyMap()

  private fun known(studentId: UUID): Boolean =
    existingStudentIds == null || studentId in existingStudentIds
}

internal fun student(studentId: UUID): StudentResponse =
  StudentResponse(studentId, "Student", null, null, null, CREATED_AT, false)

internal fun groupResponse(groupId: UUID, name: String): GroupResponse =
  GroupResponse(groupId, name, null, null, CREATED_AT)

internal fun groupRequest(name: String, vararg studentIds: UUID): CreateGroupRequest =
  CreateGroupRequest(name, BigDecimal("1000.00"), "note", studentIds.toList())

/**
 * Persists an owner so that the groups of the test satisfy the `fk_groups_owner` foreign key, and
 * returns the principal the service is called with.
 */
internal fun UserRepository.insertOwner(): JwtUser {
  val owner =
    saveAndFlush(
      OAuth2User.builder()
        .provider(OAuth2Provider.GOOGLE)
        .providerId(UUID.randomUUID().toString())
        .email(UUID.randomUUID().toString() + "@example.com")
        .build()
    )

  return JwtUser(owner.id, owner.email)
}
