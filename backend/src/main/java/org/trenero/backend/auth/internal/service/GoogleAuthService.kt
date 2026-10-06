package org.trenero.backend.auth.internal.service

import com.google.api.client.googleapis.auth.oauth2.GoogleIdToken
import com.google.api.client.googleapis.auth.oauth2.GoogleIdTokenVerifier
import java.io.IOException
import java.security.GeneralSecurityException
import org.slf4j.LoggerFactory
import org.springframework.security.authentication.BadCredentialsException
import org.springframework.stereotype.Service

@Service
class GoogleAuthService(private val verifier: GoogleIdTokenVerifier) {
  private val log = LoggerFactory.getLogger(GoogleAuthService::class.java)

  fun verifyIdToken(token: String): GoogleIdToken {
    log.info("Attempting to verify Google ID token")

    val googleIdToken =
      try {
        verifier.verify(token)
      } catch (e: Exception) {
        when (e) {
          is GeneralSecurityException,
          is IllegalArgumentException -> {
            log.error("Invalid Google ID token signature: ${e.message}", e)
            throw BadCredentialsException("Invalid Google ID token signature", e)
          }
          is IOException -> {
            log.error("Network failure during Google ID token verification: ${e.message}", e)
            throw IllegalStateException("Failed to reach Google authentication servers", e)
          }
          else -> throw e
        }
      }

    return googleIdToken ?: throw BadCredentialsException("Invalid or expired Google ID token")
  }
}
