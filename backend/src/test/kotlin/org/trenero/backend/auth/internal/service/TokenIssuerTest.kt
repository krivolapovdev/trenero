package org.trenero.backend.auth.internal.service

import java.util.UUID
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Test
import org.trenero.backend.common.domain.TokenType
import org.trenero.backend.common.security.JwtUser

class TokenIssuerTest {

  private val jwtTokenProvider = jwtTokenProvider()
  private val tokenIssuer = TokenIssuer(jwtTokenProvider)
  private val jwtUser = JwtUser(UUID.randomUUID(), "STUDENT@EXAMPLE.COM")

  @Test
  fun issuesAnAccessTokenAndARefreshToken() {
    val tokens = tokenIssuer.issue(jwtUser)

    assertThat(tokens.accessToken).isNotBlank()
    assertThat(tokens.refreshToken).isNotBlank()
    assertThat(jwtTokenProvider.isTokenValid(tokens.accessToken, TokenType.ACCESS)).isTrue()
    assertThat(jwtTokenProvider.isTokenValid(tokens.refreshToken, TokenType.REFRESH)).isTrue()
  }

  @Test
  fun carriesTheUserInsideTheAccessToken() {
    val tokens = tokenIssuer.issue(jwtUser)

    val extractedUser = jwtTokenProvider.extractUser(tokens.accessToken)

    assertThat(extractedUser.id).isEqualTo(jwtUser.id)
    assertThat(extractedUser.email).isEqualTo(jwtUser.email)
  }

  @Test
  fun doesNotStampTheRefreshTokenAsAnAccessToken() {
    val tokens = tokenIssuer.issue(jwtUser)

    assertThat(jwtTokenProvider.isTokenValid(tokens.refreshToken, TokenType.ACCESS)).isFalse()
  }
}
