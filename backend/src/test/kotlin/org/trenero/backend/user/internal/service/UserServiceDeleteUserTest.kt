package org.trenero.backend.user.internal.service

import jakarta.persistence.EntityNotFoundException
import org.assertj.core.api.Assertions.assertThat
import org.assertj.core.api.Assertions.assertThatThrownBy
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.data.jpa.test.autoconfigure.DataJpaTest
import org.springframework.context.annotation.Import
import org.trenero.backend.TestcontainersConfig
import org.trenero.backend.common.domain.OAuth2Provider
import org.trenero.backend.common.security.JwtUser
import org.trenero.backend.user.external.response.UserResponse
import org.trenero.backend.user.internal.mapper.UserMapperImpl
import org.trenero.backend.user.internal.repository.UserRepository

/**
 * The account deletion behind {@code DELETE /api/v1/users/me}. The data of the caller is removed by
 * the {@code ON DELETE CASCADE} foreign keys of the schema, so the service only has to delete the
 * account row itself.
 */
@DataJpaTest
@Import(TestcontainersConfig::class)
class UserServiceDeleteUserTest {

  @Autowired private lateinit var userRepository: UserRepository

  private fun userService() = UserService(userRepository, UserMapperImpl())

  @Test
  fun removesTheAccountOfTheCaller() {
    val user = createAccount("student@example.com")

    userService().deleteUser(JwtUser(user.id, user.email))

    assertThat(userRepository.findById(user.id).isPresent).isFalse()
  }

  @Test
  fun keepsTheAccountsOfOtherUsers() {
    val owner = createAccount("owner@example.com", "owner-subject")
    val other = createAccount("other@example.com", "other-subject")

    userService().deleteUser(JwtUser(owner.id, owner.email))

    assertThat(userRepository.count()).isEqualTo(1)
    assertThat(userRepository.findById(other.id).isPresent).isTrue()
  }

  @Test
  fun rejectsDeletingAnAccountThatIsAlreadyGone() {
    val user = createAccount("student@example.com")
    val jwtUser = JwtUser(user.id, user.email)

    userService().deleteUser(jwtUser)

    assertThatThrownBy { userService().deleteUser(jwtUser) }
      .isInstanceOf(EntityNotFoundException::class.java)
  }

  private fun createAccount(
    email: String,
    providerId: String = "google-subject",
  ): UserResponse =
    userService().getOrCreateUserFromOAuth2(OAuth2Provider.GOOGLE, providerId, email)
}
