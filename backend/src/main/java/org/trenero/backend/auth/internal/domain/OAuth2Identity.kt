package org.trenero.backend.auth.internal.domain

import org.trenero.backend.common.domain.OAuth2Provider

data class OAuth2Identity(
  val provider: OAuth2Provider,
  val providerId: String,
  val email: String,
)
