package org.trenero.backend.auth.internal.service

import com.google.api.client.googleapis.auth.oauth2.GoogleIdToken
import com.google.api.client.googleapis.auth.oauth2.GoogleIdTokenVerifier
import java.io.IOException
import java.security.GeneralSecurityException
import org.slf4j.LoggerFactory
import org.springframework.stereotype.Service
import org.trenero.backend.auth.internal.domain.OAuth2Identity
import org.trenero.backend.auth.internal.exception.IdentityProviderUnavailableException
import org.trenero.backend.auth.internal.exception.InvalidGoogleTokenException
import org.trenero.backend.auth.internal.port.GoogleIdentityVerifier
import org.trenero.backend.common.domain.OAuth2Provider

@Service
class GoogleIdTokenIdentityVerifier(private val idTokenVerifier: GoogleIdTokenVerifier) :
  GoogleIdentityVerifier {
  private val log = LoggerFactory.getLogger(javaClass)

  private companion object {
    const val INVALID_TOKEN_MESSAGE = "Invalid or expired Google identity token"
    const val INVALID_SIGNATURE_MESSAGE = "Invalid Google identity token signature"
    const val MALFORMED_TOKEN_MESSAGE = "Malformed Google identity token"
    const val MISSING_SUBJECT_MESSAGE = "Google identity token does not contain a subject"
    const val MISSING_EMAIL_MESSAGE = "Google identity token does not contain an email"
    const val PROVIDER_UNAVAILABLE_MESSAGE = "Failed to reach Google authentication servers"
  }

  override fun verify(identityToken: String): OAuth2Identity {
    log.info("Verifying Google identity token")

    return verifyIdToken(identityToken).toIdentity()
  }

  private fun verifyIdToken(identityToken: String): GoogleIdToken =
    try {
      idTokenVerifier.verify(identityToken)
        ?: throw InvalidGoogleTokenException(INVALID_TOKEN_MESSAGE)
    } catch (e: GeneralSecurityException) {
      log.error("Google identity token signature is invalid", e)
      throw InvalidGoogleTokenException(INVALID_SIGNATURE_MESSAGE, e)
    } catch (e: IllegalArgumentException) {
      log.error("Google identity token is malformed", e)
      throw InvalidGoogleTokenException(MALFORMED_TOKEN_MESSAGE, e)
    } catch (e: IOException) {
      log.error("Google identity provider is unreachable", e)
      throw IdentityProviderUnavailableException(PROVIDER_UNAVAILABLE_MESSAGE, e)
    }

  private fun GoogleIdToken.toIdentity(): OAuth2Identity {
    val providerId = payload.subject ?: throw InvalidGoogleTokenException(MISSING_SUBJECT_MESSAGE)
    val email = payload.email ?: throw InvalidGoogleTokenException(MISSING_EMAIL_MESSAGE)

    return OAuth2Identity(OAuth2Provider.GOOGLE, providerId, email)
  }
}
