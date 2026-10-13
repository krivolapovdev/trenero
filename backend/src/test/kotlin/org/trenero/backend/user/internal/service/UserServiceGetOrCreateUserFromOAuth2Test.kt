package org.trenero.backend.user.internal.service

import java.util.Locale
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.data.jpa.test.autoconfigure.DataJpaTest
import org.springframework.context.annotation.Import
import org.trenero.backend.TestcontainersConfig
import org.trenero.backend.common.domain.OAuth2Provider
import org.trenero.backend.user.internal.mapper.UserMapperImpl
import org.trenero.backend.user.internal.repository.UserRepository

/**
 * Sign-in of the user module: the account is resolved by the provider identity and created on the
 * first login. The row this service returns is the owner of every other module of the caller.
 */
@DataJpaTest
@Import(TestcontainersConfig::class)
class UserServiceGetOrCreateUserFromOAuth2Test {

  @Autowired private lateinit var userRepository: UserRepository

  private fun userService() = UserService(userRepository, UserMapperImpl())

  @Test
  fun createsTheAccountOnTheFirstLogin() {
    val user =
      userService()
        .getOrCreateUserFromOAuth2(OAuth2Provider.GOOGLE, "google-subject", "student@example.com")

    val stored = userRepository.findById(user.id).orElseThrow()

    assertThat(stored.provider).isEqualTo(OAuth2Provider.GOOGLE)
    assertThat(stored.providerId).isEqualTo("google-subject")
    assertThat(stored.email).isEqualTo("STUDENT@EXAMPLE.COM")
    assertThat(stored.createdAt).isNotNull()
  }

  @Test
  fun returnsTheStoredAccountOnTheNextLogin() {
    val first =
      userService()
        .getOrCreateUserFromOAuth2(OAuth2Provider.GOOGLE, "google-subject", "student@example.com")
    val second =
      userService()
        .getOrCreateUserFromOAuth2(OAuth2Provider.GOOGLE, "google-subject", "student@example.com")

    assertThat(second.id).isEqualTo(first.id)
    assertThat(userRepository.count()).isEqualTo(1)
  }

  @Test
  fun normalizesTheEmailOfANewAccount() {
    val user =
      userService()
        .getOrCreateUserFromOAuth2(
          OAuth2Provider.GOOGLE,
          "google-subject",
          "  Student@Example.COM  ",
        )

    assertThat(user.email).isEqualTo("STUDENT@EXAMPLE.COM")
  }

  /**
   * The email is the only part of the identity that is upper-cased, and it is upper-cased through
   * {@code String.toUpperCase()}, which uses the JVM default locale. On a Turkish JVM a lower-case
   * {@code i} becomes the dotted {@code İ}, so the address stored for the account - and the address
   * that is stamped into the issued token - comes out corrupted.
   */
  @Test
  fun upperCasesTheEmailIndependentlyOfTheJvmLocale() {
    val defaultLocale = Locale.getDefault()

    try {
      Locale.setDefault(Locale.forLanguageTag("tr-TR"))

      val user =
        userService()
          .getOrCreateUserFromOAuth2(OAuth2Provider.GOOGLE, "google-subject", "ivan@example.com")

      assertThat(user.email).isEqualTo("IVAN@EXAMPLE.COM")
    } finally {
      Locale.setDefault(defaultLocale)
    }
  }

  @Test
  fun keepsTheAccountsOfDifferentProvidersApart() {
    val google =
      userService()
        .getOrCreateUserFromOAuth2(OAuth2Provider.GOOGLE, "shared-id", "student@example.com")
    val apple =
      userService()
        .getOrCreateUserFromOAuth2(OAuth2Provider.APPLE, "shared-id", "student@example.com")

    assertThat(apple.id).isNotEqualTo(google.id)
    assertThat(userRepository.count()).isEqualTo(2)
  }

  /**
   * The account is resolved by the provider identity alone, so the email of a returning account is
   * never refreshed. The address that was stored first keeps being returned - and put into the
   * token - even after the provider reports a new one.
   */
  @Test
  fun keepsTheEmailOfTheFirstLoginWhenTheProviderReportsANewOne() {
    val first =
      userService()
        .getOrCreateUserFromOAuth2(OAuth2Provider.GOOGLE, "google-subject", "old@example.com")
    val second =
      userService()
        .getOrCreateUserFromOAuth2(OAuth2Provider.GOOGLE, "google-subject", "new@example.com")

    assertThat(second.id).isEqualTo(first.id)
    assertThat(second.email).isEqualTo("OLD@EXAMPLE.COM")
  }
}
