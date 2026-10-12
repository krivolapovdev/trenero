package org.trenero.backend.user.external.spi

import java.util.UUID
import org.trenero.backend.common.domain.OAuth2Provider
import org.trenero.backend.user.external.response.UserResponse

interface UserSpi {
  fun getOrCreateUserFromOAuth2(
    provider: OAuth2Provider,
    providerId: String,
    email: String,
  ): UserResponse

  fun existsById(id: UUID): Boolean
}
