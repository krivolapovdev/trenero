package org.trenero.backend.auth.internal.service

import org.slf4j.LoggerFactory
import org.springframework.context.annotation.Lazy
import org.springframework.security.authentication.BadCredentialsException
import org.springframework.stereotype.Service
import org.trenero.backend.auth.external.response.LoginResponse
import org.trenero.backend.auth.internal.config.ReviewerProperties
import org.trenero.backend.common.domain.OAuth2Provider
import org.trenero.backend.common.security.JwtUser
import org.trenero.backend.user.external.spi.UserSpi

@Service
class ReviewerAuthService(
  private val jwtService: JwtService,
  private val reviewerProperties: ReviewerProperties,
  @Lazy private val userSpi: UserSpi,
) {
  private val log = LoggerFactory.getLogger(ReviewerAuthService::class.java)

  fun isValidKey(key: String): Boolean = reviewerProperties.key == key

  fun login(incomingKey: String): LoginResponse {
    log.info("Attempting reviewer authentication")

    if (!isValidKey(incomingKey)) {
      throw BadCredentialsException("Invalid reviewer key")
    }

    val user =
      userSpi.getOrCreateUserFromOAuth2(
        OAuth2Provider.GOOGLE,
        "REVIEWER",
        "REVIEWER@TRENERO.ORG",
      )

    val jwtUser = JwtUser(user.id, user.email)
    val tokens = jwtService.createAccessAndRefreshTokens(jwtUser)

    return LoginResponse(user, tokens)
  }
}
