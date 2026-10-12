package org.trenero.backend.auth.internal.service

import org.slf4j.LoggerFactory
import org.springframework.stereotype.Service
import org.trenero.backend.auth.external.response.JwtResponse
import org.trenero.backend.common.security.JwtTokenProvider
import org.trenero.backend.common.security.JwtUser

@Service
class TokenIssuer(private val jwtTokenProvider: JwtTokenProvider) {
  private val log = LoggerFactory.getLogger(javaClass)

  fun issue(jwtUser: JwtUser): JwtResponse {
    log.info("Issuing access and refresh tokens for user id={}", jwtUser.id)

    val accessToken = jwtTokenProvider.generateAccessToken(jwtUser)
    val refreshToken = jwtTokenProvider.generateRefreshToken(jwtUser)

    return JwtResponse(accessToken = accessToken, refreshToken = refreshToken)
  }
}
