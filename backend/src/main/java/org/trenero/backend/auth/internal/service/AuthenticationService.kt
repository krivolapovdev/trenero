package org.trenero.backend.auth.internal.service

import org.slf4j.LoggerFactory
import org.springframework.stereotype.Service
import org.trenero.backend.auth.external.response.LoginResponse
import org.trenero.backend.auth.internal.domain.OAuth2Identity
import org.trenero.backend.common.security.JwtUser
import org.trenero.backend.user.external.spi.UserSpi

@Service
class AuthenticationService(
  private val tokenIssuer: TokenIssuer,
  private val userSpi: UserSpi,
) {
  private val log = LoggerFactory.getLogger(javaClass)

  fun establishSession(identity: OAuth2Identity): LoginResponse {
    log.info("Establishing session for provider={}", identity.provider)

    val user =
      userSpi.getOrCreateUserFromOAuth2(
        identity.provider,
        identity.providerId,
        identity.email,
      )

    val tokens = tokenIssuer.issue(JwtUser(user.id, user.email))

    return LoginResponse(user = user, jwtTokens = tokens)
  }
}
