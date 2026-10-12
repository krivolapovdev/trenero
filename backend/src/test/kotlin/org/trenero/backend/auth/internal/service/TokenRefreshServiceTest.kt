package org.trenero.backend.auth.internal.service

import java.time.Duration
import java.util.UUID
import org.assertj.core.api.Assertions.assertThat
import org.assertj.core.api.Assertions.assertThatThrownBy
import org.junit.jupiter.api.Test
import org.trenero.backend.auth.internal.exception.InvalidRefreshTokenException
import org.trenero.backend.common.domain.TokenType
import org.trenero.backend.common.security.JwtUser

class TokenRefreshServiceTest {

  private val jwtTokenProvider = jwtTokenProvider()
  private val tokenIssuer = TokenIssuer(jwtTokenProvider)
  private val tokenRefreshService = TokenRefreshService(jwtTokenProvider, tokenIssuer)

  @Test
  fun rotatesTheTokenPairForAValidRefreshToken() {
    val jwtUser = JwtUser(UUID.randomUUID(), "STUDENT@EXAMPLE.COM")
    val refreshToken = jwtTokenProvider.generateRefreshToken(jwtUser)

    val rotatedTokens = tokenRefreshService.refresh(refreshToken)

    assertThat(jwtTokenProvider.isTokenValid(rotatedTokens.accessToken, TokenType.ACCESS)).isTrue()
    assertThat(jwtTokenProvider.isTokenValid(rotatedTokens.refreshToken, TokenType.REFRESH))
      .isTrue()
    assertThat(jwtTokenProvider.extractUser(rotatedTokens.accessToken).id).isEqualTo(jwtUser.id)
  }

  @Test
  fun rejectsAMalformedRefreshToken() {
    assertThatThrownBy { tokenRefreshService.refresh("not-a-refresh-token") }
      .isInstanceOf(InvalidRefreshTokenException::class.java)
  }

  @Test
  fun rejectsAnAccessTokenUsedAsARefreshToken() {
    val accessToken =
      jwtTokenProvider.generateAccessToken(JwtUser(UUID.randomUUID(), "STUDENT@EXAMPLE.COM"))

    assertThatThrownBy { tokenRefreshService.refresh(accessToken) }
      .isInstanceOf(InvalidRefreshTokenException::class.java)
  }

  @Test
  fun rejectsAnExpiredRefreshToken() {
    val expiredProvider = jwtTokenProvider(refreshTokenExpiration = Duration.ofSeconds(-1))
    val service = TokenRefreshService(expiredProvider, TokenIssuer(expiredProvider))
    val expiredRefreshToken =
      expiredProvider.generateRefreshToken(JwtUser(UUID.randomUUID(), "STUDENT@EXAMPLE.COM"))

    assertThatThrownBy { service.refresh(expiredRefreshToken) }
      .isInstanceOf(InvalidRefreshTokenException::class.java)
  }
}
