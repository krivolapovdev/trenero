package org.trenero.backend.auth.internal.service

import java.util.UUID
import org.assertj.core.api.Assertions.assertThat
import org.assertj.core.api.Assertions.assertThatThrownBy
import org.junit.jupiter.api.Test
import org.trenero.backend.auth.internal.config.ReviewerProperties
import org.trenero.backend.auth.internal.exception.InvalidReviewerKeyException
import org.trenero.backend.common.domain.OAuth2Provider
import org.trenero.backend.common.domain.TokenType
import org.trenero.backend.user.external.response.UserResponse
import org.trenero.backend.user.external.spi.UserSpi

class ReviewerLoginServiceTest {

  private val jwtTokenProvider = jwtTokenProvider()
  private val tokenIssuer = TokenIssuer(jwtTokenProvider)
  private val configuredKey = "super-secret-reviewer-key"
  private val reviewerUser = UserResponse(UUID.randomUUID(), "REVIEWER@TRENERO.ORG")

  @Test
  fun signsInTheReviewerWithAValidKey() {
    val userSpi = RecordingUserSpi(reviewerUser)

    val session = reviewerLoginService(userSpi).login(configuredKey)

    assertThat(userSpi.lastProvider).isEqualTo(OAuth2Provider.GOOGLE)
    assertThat(userSpi.lastProviderId).isEqualTo("REVIEWER")
    assertThat(userSpi.lastEmail).isEqualTo("REVIEWER@TRENERO.ORG")
    assertThat(session.user).isEqualTo(reviewerUser)
    assertThat(jwtTokenProvider.isTokenValid(session.jwtTokens.accessToken, TokenType.ACCESS))
      .isTrue()
  }

  @Test
  fun rejectsAnInvalidKeyWithoutResolvingAUser() {
    val userSpi = RecordingUserSpi(reviewerUser)

    assertThatThrownBy { reviewerLoginService(userSpi).login("wrong-key") }
      .isInstanceOf(InvalidReviewerKeyException::class.java)
    assertThat(userSpi.invocationCount).isZero()
  }

  private fun reviewerLoginService(userSpi: UserSpi): ReviewerLoginService =
    ReviewerLoginService(
      ReviewerKeyValidator(ReviewerProperties(key = configuredKey)),
      AuthenticationService(tokenIssuer, userSpi),
    )
}
