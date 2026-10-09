package org.trenero.backend.group.external.spi

import java.time.LocalDate
import java.util.*
import org.trenero.backend.common.security.JwtUser
import org.trenero.backend.group.external.response.GroupStudentResponse

interface GroupStudentSpi {
  fun getStudentsByGroupId(groupId: UUID, jwtUser: JwtUser): List<GroupStudentResponse>

  fun getGroupsByStudentId(studentId: UUID, jwtUser: JwtUser): List<GroupStudentResponse>

  fun getGroupStudentsByStudentIds(
    studentIds: List<UUID>,
    jwtUser: JwtUser,
  ): Map<UUID, GroupStudentResponse>

  fun addStudentToGroup(
    studentId: UUID,
    groupId: UUID,
    joinedAt: LocalDate?,
    jwtUser: JwtUser,
  )

  fun removeStudentFromGroup(studentId: UUID, groupId: UUID, jwtUser: JwtUser)
}
