package org.trenero.backend.auth.internal.service

import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Test
import org.trenero.backend.auth.internal.config.ReviewerProperties

class ReviewerKeyValidatorTest {

  private val configuredKey = "super-secret-reviewer-key"
  private val reviewerKeyValidator = ReviewerKeyValidator(ReviewerProperties(key = configuredKey))

  @Test
  fun acceptsTheConfiguredReviewerKey() {
    assertThat(reviewerKeyValidator.isValid(configuredKey)).isTrue()
  }

  @Test
  fun rejectsADifferentReviewerKey() {
    assertThat(reviewerKeyValidator.isValid("another-key")).isFalse()
  }

  @Test
  fun rejectsAnEmptyReviewerKey() {
    assertThat(reviewerKeyValidator.isValid("")).isFalse()
  }
}
