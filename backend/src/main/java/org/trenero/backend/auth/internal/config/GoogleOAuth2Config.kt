package org.trenero.backend.auth.internal.config

import com.google.api.client.googleapis.auth.oauth2.GoogleIdTokenVerifier
import com.google.api.client.googleapis.javanet.GoogleNetHttpTransport
import com.google.api.client.json.gson.GsonFactory
import org.springframework.beans.factory.annotation.Value
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration

@Configuration
class GoogleOAuth2Config {

  @Bean
  fun googleIdTokenVerifier(
    @Value($$"${app.oauth2.google.client-id}") clientIds: List<String>
  ): GoogleIdTokenVerifier {
    return GoogleIdTokenVerifier.Builder(
        GoogleNetHttpTransport.newTrustedTransport(),
        GsonFactory.getDefaultInstance(),
      )
      .setAudience(clientIds)
      .build()
  }
}
