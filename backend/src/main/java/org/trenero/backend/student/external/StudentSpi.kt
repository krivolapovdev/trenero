package org.trenero.backend.student.external

import java.util.UUID
import org.trenero.backend.common.response.StudentResponse
import org.trenero.backend.common.response.StudentWithStatusesResponse
import org.trenero.backend.common.security.JwtUser

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
}
