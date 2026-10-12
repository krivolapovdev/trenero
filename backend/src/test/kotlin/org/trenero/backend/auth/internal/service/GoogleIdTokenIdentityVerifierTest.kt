package org.trenero.backend.auth.internal.service

import com.google.api.client.googleapis.auth.oauth2.GoogleIdToken
import com.google.api.client.googleapis.auth.oauth2.GoogleIdTokenVerifier
import com.google.api.client.json.webtoken.JsonWebSignature
import java.io.IOException
import java.security.GeneralSecurityException
import org.assertj.core.api.Assertions.assertThat
import org.assertj.core.api.Assertions.assertThatThrownBy
import org.junit.jupiter.api.Test
import org.mockito.BDDMockito.given
import org.mockito.Mockito.mock
import org.trenero.backend.auth.internal.domain.OAuth2Identity
import org.trenero.backend.auth.internal.exception.IdentityProviderUnavailableException
import org.trenero.backend.auth.internal.exception.InvalidGoogleTokenException
import org.trenero.backend.common.domain.OAuth2Provider

class GoogleIdTokenIdentityVerifierTest {

  private val idTokenVerifier = mock(GoogleIdTokenVerifier::class.java)
  private val identityVerifier = GoogleIdTokenIdentityVerifier(idTokenVerifier)

  @Test
  fun mapsAVerifiedGoogleTokenToAnIdentity() {
    given(idTokenVerifier.verify(IDENTITY_TOKEN))
      .willReturn(googleIdToken(subject = "google-subject", email = "student@example.com"))

    val identity = identityVerifier.verify(IDENTITY_TOKEN)

    assertThat(identity)
      .isEqualTo(OAuth2Identity(OAuth2Provider.GOOGLE, "google-subject", "student@example.com"))
  }

  @Test
  fun rejectsATokenGoogleCannotVerify() {
    given(idTokenVerifier.verify(IDENTITY_TOKEN)).willReturn(null)

    assertThatThrownBy { identityVerifier.verify(IDENTITY_TOKEN) }
      .isInstanceOf(InvalidGoogleTokenException::class.java)
  }

  @Test
  fun rejectsATokenWithAnInvalidSignature() {
    given(idTokenVerifier.verify(IDENTITY_TOKEN))
      .willThrow(GeneralSecurityException("invalid signature"))

    assertThatThrownBy { identityVerifier.verify(IDENTITY_TOKEN) }
      .isInstanceOf(InvalidGoogleTokenException::class.java)
  }

  @Test
  fun rejectsAMalformedToken() {
    given(idTokenVerifier.verify(IDENTITY_TOKEN)).willThrow(IllegalArgumentException("malformed"))

    assertThatThrownBy { identityVerifier.verify(IDENTITY_TOKEN) }
      .isInstanceOf(InvalidGoogleTokenException::class.java)
  }

  @Test
  fun reportsTheProviderAsUnavailableWhenGoogleCannotBeReached() {
    given(idTokenVerifier.verify(IDENTITY_TOKEN)).willThrow(IOException("network is down"))

    assertThatThrownBy { identityVerifier.verify(IDENTITY_TOKEN) }
      .isInstanceOf(IdentityProviderUnavailableException::class.java)
  }

  @Test
  fun rejectsATokenWithoutAnEmail() {
    given(idTokenVerifier.verify(IDENTITY_TOKEN))
      .willReturn(googleIdToken(subject = "google-subject", email = null))

    assertThatThrownBy { identityVerifier.verify(IDENTITY_TOKEN) }
      .isInstanceOf(InvalidGoogleTokenException::class.java)
  }

  @Test
  fun rejectsATokenWithoutASubject() {
    given(idTokenVerifier.verify(IDENTITY_TOKEN))
      .willReturn(googleIdToken(subject = null, email = "student@example.com"))

    assertThatThrownBy { identityVerifier.verify(IDENTITY_TOKEN) }
      .isInstanceOf(InvalidGoogleTokenException::class.java)
  }

  private fun googleIdToken(subject: String?, email: String?): GoogleIdToken {
    val payload = GoogleIdToken.Payload().setSubject(subject).setEmail(email)

    return GoogleIdToken(JsonWebSignature.Header(), payload, ByteArray(0), ByteArray(0))
  }

  private companion object {
    const val IDENTITY_TOKEN = "google-id-token"
  }
}
