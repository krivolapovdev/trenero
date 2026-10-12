package org.trenero.backend.auth.internal.service

import org.slf4j.LoggerFactory
import org.springframework.stereotype.Service
import org.trenero.backend.auth.external.response.LoginResponse
import org.trenero.backend.auth.internal.domain.OAuth2Identity
import org.trenero.backend.auth.internal.exception.InvalidReviewerKeyException
import org.trenero.backend.common.domain.OAuth2Provider

@Service
class ReviewerLoginService(
  private val reviewerKeyValidator: ReviewerKeyValidator,
  private val authenticationService: AuthenticationService,
) {
  private val log = LoggerFactory.getLogger(javaClass)

  private companion object {
    const val REVIEWER_PROVIDER_ID = "REVIEWER"
    const val REVIEWER_EMAIL = "REVIEWER@TRENERIO.RU"

    val REVIEWER_IDENTITY =
      OAuth2Identity(
        provider = OAuth2Provider.GOOGLE,
        providerId = REVIEWER_PROVIDER_ID,
        email = REVIEWER_EMAIL,
      )
  }

  fun login(reviewerKey: String): LoginResponse {
    log.info("Processing reviewer login")

    if (!reviewerKeyValidator.isValid(reviewerKey)) {
      throw InvalidReviewerKeyException()
    }

    return authenticationService.establishSession(REVIEWER_IDENTITY)
  }
}
