package org.trenero.backend.auth.internal.service

import java.time.Duration
import org.trenero.backend.auth.internal.domain.OAuth2Identity
import org.trenero.backend.auth.internal.port.GoogleIdentityVerifier
import org.trenero.backend.common.config.JwtProperties
import org.trenero.backend.common.domain.OAuth2Provider
import org.trenero.backend.common.security.JwtTokenProvider
import org.trenero.backend.user.external.response.UserResponse
import org.trenero.backend.user.external.spi.UserSpi

internal fun jwtTokenProvider(
  secretKey: String = "test-secret-key-with-at-least-thirty-two-bytes",
  accessTokenExpiration: Duration = Duration.ofMinutes(15),
  refreshTokenExpiration: Duration = Duration.ofDays(14),
): JwtTokenProvider {
  val properties = JwtProperties()
  properties.secretKey = secretKey
  properties.accessTokenExpiration = accessTokenExpiration
  properties.refreshTokenExpiration = refreshTokenExpiration

  return JwtTokenProvider(properties).also { it.init() }
}

internal class RecordingUserSpi(private val user: UserResponse) : UserSpi {
  var lastProvider: OAuth2Provider? = null
  var lastProviderId: String? = null
  var lastEmail: String? = null
  var invocationCount: Int = 0

  override fun getOrCreateUserFromOAuth2(
    provider: OAuth2Provider,
    providerId: String,
    email: String,
  ): UserResponse {
    lastProvider = provider
    lastProviderId = providerId
    lastEmail = email
    invocationCount++

    return user
  }
}

internal class FakeGoogleIdentityVerifier(private val identity: OAuth2Identity) :
  GoogleIdentityVerifier {
  var lastIdentityToken: String? = null

  override fun verify(identityToken: String): OAuth2Identity {
    lastIdentityToken = identityToken
    return identity
  }
}
