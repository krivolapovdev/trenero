package org.trenero.backend.student.internal.service

import java.util.UUID
import java.util.concurrent.Executor
import org.mockito.Mockito
import org.mockito.Mockito.mock
import org.trenero.backend.common.domain.OAuth2Provider
import org.trenero.backend.common.security.JwtUser
import org.trenero.backend.group.external.spi.GroupStudentSpi
import org.trenero.backend.student.internal.domain.Student
import org.trenero.backend.student.internal.mapper.StudentMapperImpl
import org.trenero.backend.student.internal.repository.StudentRepository
import org.trenero.backend.user.internal.domain.OAuth2User
import org.trenero.backend.user.internal.repository.UserRepository

/**
 * Builds the service under test. The service writes its rows through its own `self` reference (so
 * that the call runs behind a proxy); the stub delegates that write to the repository, which keeps
 * the persistence real. The collaborators of the other modules stay empty because the profile
 * writes do not use them.
 */
internal fun studentService(
  studentRepository: StudentRepository,
  groupStudentSpi: GroupStudentSpi = mock(GroupStudentSpi::class.java),
): StudentService {
  val self = mock(StudentService::class.java)
  Mockito.`when`(self.saveStudent(Mockito.any<Student>())).thenAnswer { invocation ->
    studentRepository.saveAndFlush(invocation.getArgument(0))
  }

  return StudentService(
    studentRepository,
    StudentMapperImpl(),
    self,
    StudentStatusService(),
    null,
    groupStudentSpi,
    null,
    null,
    null,
    Executor { it.run() },
  )
}

/**
 * Persists an owner so that the students of the test satisfy the `fk_students_owner` foreign key,
 * and returns the principal the service is called with.
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
