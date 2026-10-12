package org.trenero.backend.auth.internal.service

import java.util.UUID
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Test
import org.trenero.backend.auth.internal.domain.OAuth2Identity
import org.trenero.backend.common.domain.OAuth2Provider
import org.trenero.backend.common.domain.TokenType
import org.trenero.backend.user.external.response.UserResponse

class AuthenticationServiceTest {

  private val jwtTokenProvider = jwtTokenProvider()
  private val tokenIssuer = TokenIssuer(jwtTokenProvider)
  private val user = UserResponse(UUID.randomUUID(), "STUDENT@EXAMPLE.COM")

  @Test
  fun resolvesTheUserAndIssuesTokensForTheVerifiedIdentity() {
    val userSpi = RecordingUserSpi(user)
    val authenticationService = AuthenticationService(tokenIssuer, userSpi)
    val identity =
      OAuth2Identity(
        provider = OAuth2Provider.GOOGLE,
        providerId = "google-subject",
        email = "student@example.com",
      )

    val session = authenticationService.establishSession(identity)

    assertThat(userSpi.lastProvider).isEqualTo(OAuth2Provider.GOOGLE)
    assertThat(userSpi.lastProviderId).isEqualTo("google-subject")
    assertThat(userSpi.lastEmail).isEqualTo("student@example.com")
    assertThat(session.user).isEqualTo(user)
  }

  @Test
  fun stampsTheIssuedTokensWithTheResolvedUser() {
    val userSpi = RecordingUserSpi(user)
    val authenticationService = AuthenticationService(tokenIssuer, userSpi)
    val identity = OAuth2Identity(OAuth2Provider.GOOGLE, "google-subject", "student@example.com")

    val session = authenticationService.establishSession(identity)

    val accessToken = session.jwtTokens.accessToken
    assertThat(jwtTokenProvider.isTokenValid(accessToken, TokenType.ACCESS)).isTrue()
    assertThat(jwtTokenProvider.extractUser(accessToken).id).isEqualTo(user.id)
    assertThat(jwtTokenProvider.extractUser(accessToken).email).isEqualTo(user.email)
  }
}
