package org.trenero.backend.user.internal.service

import java.util.UUID
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.data.jpa.test.autoconfigure.DataJpaTest
import org.springframework.context.annotation.Import
import org.trenero.backend.TestcontainersConfig
import org.trenero.backend.common.domain.OAuth2Provider
import org.trenero.backend.common.security.JwtUser
import org.trenero.backend.user.internal.mapper.UserMapperImpl
import org.trenero.backend.user.internal.repository.UserRepository

/**
 * {@link UserService#existsById} guards the refresh flow: a token is rejected once the account it
 * belongs to is gone.
 */
@DataJpaTest
@Import(TestcontainersConfig::class)
class UserServiceExistsByIdTest {

  @Autowired private lateinit var userRepository: UserRepository

  private fun userService() = UserService(userRepository, UserMapperImpl())

  @Test
  fun reportsAStoredAccountAsExisting() {
    val user =
      userService()
        .getOrCreateUserFromOAuth2(OAuth2Provider.GOOGLE, "google-subject", "student@example.com")

    assertThat(userService().existsById(user.id)).isTrue()
  }

  @Test
  fun reportsAnUnknownIdAsMissing() {
    assertThat(userService().existsById(UUID.randomUUID())).isFalse()
  }

  @Test
  fun reportsADeletedAccountAsMissing() {
    val user =
      userService()
        .getOrCreateUserFromOAuth2(OAuth2Provider.GOOGLE, "google-subject", "student@example.com")

    userService().deleteUser(JwtUser(user.id, user.email))

    assertThat(userService().existsById(user.id)).isFalse()
  }
}
