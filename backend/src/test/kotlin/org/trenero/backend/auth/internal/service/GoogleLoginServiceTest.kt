package org.trenero.backend.auth.internal.service

import java.util.UUID
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Test
import org.trenero.backend.auth.internal.domain.OAuth2Identity
import org.trenero.backend.common.domain.OAuth2Provider
import org.trenero.backend.common.domain.TokenType
import org.trenero.backend.user.external.response.UserResponse

class GoogleLoginServiceTest {

  private val jwtTokenProvider = jwtTokenProvider()
  private val tokenIssuer = TokenIssuer(jwtTokenProvider)
  private val user = UserResponse(UUID.randomUUID(), "STUDENT@EXAMPLE.COM")

  @Test
  fun verifiesTheTokenAndEstablishesASession() {
    val identity = OAuth2Identity(OAuth2Provider.GOOGLE, "google-subject", "student@example.com")
    val identityVerifier = FakeGoogleIdentityVerifier(identity)
    val userSpi = RecordingUserSpi(user)
    val googleLoginService =
      GoogleLoginService(identityVerifier, AuthenticationService(tokenIssuer, userSpi))

    val session = googleLoginService.login("google-id-token")

    assertThat(identityVerifier.lastIdentityToken).isEqualTo("google-id-token")
    assertThat(userSpi.lastProviderId).isEqualTo("google-subject")
    assertThat(session.user).isEqualTo(user)
    assertThat(jwtTokenProvider.isTokenValid(session.jwtTokens.refreshToken, TokenType.REFRESH))
      .isTrue()
  }
}
