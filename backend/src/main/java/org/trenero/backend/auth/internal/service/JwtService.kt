package org.trenero.backend.auth.internal.service

import org.slf4j.LoggerFactory
import org.springframework.security.authentication.BadCredentialsException
import org.springframework.stereotype.Service
import org.trenero.backend.auth.external.response.JwtResponse
import org.trenero.backend.auth.internal.request.RefreshTokenRequest
import org.trenero.backend.common.domain.TokenType
import org.trenero.backend.common.security.JwtTokenProvider
import org.trenero.backend.common.security.JwtUser

@Service
class JwtService(private val jwtTokenProvider: JwtTokenProvider) {
  private val log = LoggerFactory.getLogger(JwtService::class.java)

  fun createAccessAndRefreshTokens(jwtUser: JwtUser): JwtResponse {
    log.info("Creating JWT access and refresh tokens for id={}", jwtUser.id)

    val accessToken = jwtTokenProvider.generateAccessToken(jwtUser)
    val refreshToken = jwtTokenProvider.generateRefreshToken(jwtUser)

    return JwtResponse(accessToken, refreshToken)
  }

  fun refreshTokens(request: RefreshTokenRequest): JwtResponse {
    log.info("Processing token refresh request")

    val oldRefreshToken = request.refreshToken

    if (!jwtTokenProvider.isTokenValid(oldRefreshToken, TokenType.REFRESH)) {
      log.warn("Refresh token validation failed")
      throw BadCredentialsException("Invalid or expired refresh token")
    }

    val jwtUser = jwtTokenProvider.extractUser(oldRefreshToken)

    return createAccessAndRefreshTokens(jwtUser)
  }
}
