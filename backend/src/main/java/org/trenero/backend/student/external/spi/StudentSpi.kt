package org.trenero.backend.student.external.spi

import java.util.UUID
import org.trenero.backend.common.security.JwtUser
import org.trenero.backend.student.external.response.StudentResponse
import org.trenero.backend.student.external.response.StudentWithStatusesResponse

interface StudentSpi {
  fun getAllStudents(jwtUser: JwtUser): List<StudentResponse>

  fun getStudentById(studentId: UUID, jwtUser: JwtUser): StudentResponse

  fun getStudentsByIds(
    studentIds: List<UUID>,
    jwtUser: JwtUser,
  ): Map<UUID, StudentResponse>

  fun getStudentsWithStatusesByIds(
    studentIds: List<UUID>,
    jwtUser: JwtUser,
  ): Map<UUID, StudentWithStatusesResponse>

  /**
   * The students with their badges, the visit badge read from the lessons of [groupId].
   *
   * The client uses this for a group page, so the "present" and "missing" badge tells whether a
   * student came to the last lesson of that group instead of the last lesson of any group the
   * student belongs to.
   */
  fun getStudentsWithStatusesByGroupId(
    studentIds: List<UUID>,
    groupId: UUID,
    jwtUser: JwtUser,
  ): Map<UUID, StudentWithStatusesResponse>
}
