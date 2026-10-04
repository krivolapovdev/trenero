package org.trenero.backend.group.external

import java.util.*
import org.trenero.backend.common.response.GroupStudentResponse
import org.trenero.backend.common.security.JwtUser

interface GroupStudentSpi {
  fun getStudentsByGroupId(groupId: UUID, jwtUser: JwtUser): List<GroupStudentResponse>

  fun getGroupsByStudentId(studentId: UUID, jwtUser: JwtUser): List<GroupStudentResponse>

  fun getGroupStudentsByStudentIds(
    studentIds: List<UUID>,
    jwtUser: JwtUser,
  ): Map<UUID, GroupStudentResponse>

  fun addStudentToGroup(studentId: UUID, groupId: UUID, jwtUser: JwtUser)

  fun removeStudentFromGroup(studentId: UUID, groupId: UUID, jwtUser: JwtUser)
}
