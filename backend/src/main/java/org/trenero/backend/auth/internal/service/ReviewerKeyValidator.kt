package org.trenero.backend.auth.internal.service

import java.nio.charset.StandardCharsets
import java.security.MessageDigest
import org.springframework.stereotype.Component
import org.trenero.backend.auth.internal.config.ReviewerProperties

@Component
class ReviewerKeyValidator(private val reviewerProperties: ReviewerProperties) {

  fun isValid(reviewerKey: String): Boolean =
    MessageDigest.isEqual(
      reviewerKey.toByteArray(StandardCharsets.UTF_8),
      reviewerProperties.key.toByteArray(StandardCharsets.UTF_8),
    )
}
