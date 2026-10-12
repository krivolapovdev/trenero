package org.trenero.backend.auth.internal.service

import org.slf4j.LoggerFactory
import org.springframework.stereotype.Service
import org.trenero.backend.auth.external.response.JwtResponse
import org.trenero.backend.auth.internal.exception.InvalidRefreshTokenException
import org.trenero.backend.common.domain.TokenType
import org.trenero.backend.common.security.JwtTokenProvider

@Service
class TokenRefreshService(
  private val jwtTokenProvider: JwtTokenProvider,
  private val tokenIssuer: TokenIssuer,
) {
  private val log = LoggerFactory.getLogger(javaClass)

  private companion object {
    const val INVALID_REFRESH_TOKEN_MESSAGE = "Invalid or expired refresh token"
  }

  fun refresh(refreshToken: String): JwtResponse {
    log.info("Refreshing access and refresh tokens")

    if (!jwtTokenProvider.isTokenValid(refreshToken, TokenType.REFRESH)) {
      throw InvalidRefreshTokenException(INVALID_REFRESH_TOKEN_MESSAGE)
    }

    return tokenIssuer.issue(jwtTokenProvider.extractUser(refreshToken))
  }
}
