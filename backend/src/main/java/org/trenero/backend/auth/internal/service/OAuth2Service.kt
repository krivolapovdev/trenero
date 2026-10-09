package org.trenero.backend.auth.internal.service

import org.slf4j.LoggerFactory
import org.springframework.context.annotation.Lazy
import org.springframework.stereotype.Service
import org.trenero.backend.auth.external.response.LoginResponse
import org.trenero.backend.auth.internal.request.OAuth2LoginRequest
import org.trenero.backend.common.domain.OAuth2Provider
import org.trenero.backend.common.security.JwtUser
import org.trenero.backend.user.external.spi.UserSpi

@Service
class OAuth2Service(
  private val googleAuthService: GoogleAuthService,
  private val jwtService: JwtService,
  @Lazy private val userSpi: UserSpi,
) {
  private val log = LoggerFactory.getLogger(OAuth2Service::class.java)

  fun googleLogin(request: OAuth2LoginRequest): LoginResponse {
    log.info("Processing Google OAuth2 login request")

    val googleIdToken = googleAuthService.verifyIdToken(request.token)

    val payload = googleIdToken.payload
    val providerId = payload.subject
    val email = payload.email

    val user = userSpi.getOrCreateUserFromOAuth2(OAuth2Provider.GOOGLE, providerId, email)
    val jwtUser = JwtUser(user.id, user.email)
    val jwtTokens = jwtService.createAccessAndRefreshTokens(jwtUser)

    return LoginResponse(user, jwtTokens)
  }
}
