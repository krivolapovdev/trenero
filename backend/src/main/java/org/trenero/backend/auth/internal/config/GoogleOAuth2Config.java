package org.trenero.backend.auth.internal.config;

import com.google.api.client.googleapis.auth.oauth2.GoogleIdTokenVerifier;
import com.google.api.client.googleapis.javanet.GoogleNetHttpTransport;
import com.google.api.client.json.gson.GsonFactory;
import java.io.IOException;
import java.security.GeneralSecurityException;
import java.util.List;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class GoogleOAuth2Config {

  @Bean
  public GoogleIdTokenVerifier googleIdTokenVerifier(
      @Value("${app.oauth2.google.client-ids}") List<String> clientIds)
      throws GeneralSecurityException, IOException {
    return new GoogleIdTokenVerifier.Builder(
            GoogleNetHttpTransport.newTrustedTransport(), GsonFactory.getDefaultInstance())
        .setAudience(clientIds)
        .build();
  }
}
