package org.trenero.backend.group.external.spi

import java.util.UUID
import org.trenero.backend.common.security.JwtUser
import org.trenero.backend.group.external.response.GroupStudentResponse

interface GroupStudentSpi {
  fun getStudentsByGroupId(groupId: UUID, jwtUser: JwtUser): List<GroupStudentResponse>

  fun getGroupsByStudentId(studentId: UUID, jwtUser: JwtUser): List<GroupStudentResponse>

  fun getGroupStudentsByStudentIds(
    studentIds: List<UUID>,
    jwtUser: JwtUser,
  ): Map<UUID, List<GroupStudentResponse>>

  fun addStudentToGroup(
    studentId: UUID,
    groupId: UUID,
    jwtUser: JwtUser,
  )

  fun removeStudentFromGroup(studentId: UUID, groupId: UUID, jwtUser: JwtUser)
}
