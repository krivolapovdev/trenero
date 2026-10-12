package org.trenero.backend.auth.internal.service

import org.slf4j.LoggerFactory
import org.springframework.stereotype.Service
import org.trenero.backend.auth.external.response.LoginResponse
import org.trenero.backend.auth.internal.port.GoogleIdentityVerifier

@Service
class GoogleLoginService(
  private val googleIdentityVerifier: GoogleIdentityVerifier,
  private val authenticationService: AuthenticationService,
) {
  private val log = LoggerFactory.getLogger(javaClass)

  fun login(identityToken: String): LoginResponse {
    log.info("Processing Google login")

    return authenticationService.establishSession(googleIdentityVerifier.verify(identityToken))
  }
}
