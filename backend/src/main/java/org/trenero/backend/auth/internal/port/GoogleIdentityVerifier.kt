package org.trenero.backend.auth.internal.port

import org.trenero.backend.auth.internal.domain.OAuth2Identity

interface GoogleIdentityVerifier {
  fun verify(identityToken: String): OAuth2Identity
}
