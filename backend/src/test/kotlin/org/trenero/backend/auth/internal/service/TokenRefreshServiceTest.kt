package org.trenero.backend.auth.internal.service

import java.time.Duration
import java.util.UUID
import org.assertj.core.api.Assertions.assertThat
import org.assertj.core.api.Assertions.assertThatThrownBy
import org.junit.jupiter.api.Test
import org.trenero.backend.auth.internal.exception.InvalidRefreshTokenException
import org.trenero.backend.common.domain.TokenType
import org.trenero.backend.common.security.JwtUser
import org.trenero.backend.user.external.response.UserResponse

class TokenRefreshServiceTest {

  private val jwtTokenProvider = jwtTokenProvider()
  private val tokenIssuer = TokenIssuer(jwtTokenProvider)
  private val jwtUser = JwtUser(UUID.randomUUID(), "STUDENT@EXAMPLE.COM")
  private val existingUserSpi =
    RecordingUserSpi(UserResponse(jwtUser.id, jwtUser.email), setOf(jwtUser.id))
  private val tokenRefreshService =
    TokenRefreshService(jwtTokenProvider, tokenIssuer, existingUserSpi)

  @Test
  fun rotatesTheTokenPairForAValidRefreshToken() {
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
    val accessToken = jwtTokenProvider.generateAccessToken(jwtUser)

    assertThatThrownBy { tokenRefreshService.refresh(accessToken) }
      .isInstanceOf(InvalidRefreshTokenException::class.java)
  }

  @Test
  fun rejectsAnExpiredRefreshToken() {
    val expiredProvider = jwtTokenProvider(refreshTokenExpiration = Duration.ofSeconds(-1))
    val service =
      TokenRefreshService(expiredProvider, TokenIssuer(expiredProvider), existingUserSpi)
    val expiredRefreshToken = expiredProvider.generateRefreshToken(jwtUser)

    assertThatThrownBy { service.refresh(expiredRefreshToken) }
      .isInstanceOf(InvalidRefreshTokenException::class.java)
  }

  @Test
  fun rejectsARefreshTokenWhoseUserNoLongerExists() {
    val deletedUserSpi =
      RecordingUserSpi(UserResponse(UUID.randomUUID(), "DELETED@EXAMPLE.COM"), emptySet())
    val service = TokenRefreshService(jwtTokenProvider, tokenIssuer, deletedUserSpi)
    val refreshToken = jwtTokenProvider.generateRefreshToken(jwtUser)

    assertThatThrownBy { service.refresh(refreshToken) }
      .isInstanceOf(InvalidRefreshTokenException::class.java)
  }
}
