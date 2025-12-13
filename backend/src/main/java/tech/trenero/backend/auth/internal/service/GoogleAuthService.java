package tech.trenero.backend.auth.internal.service;

import com.google.api.client.googleapis.auth.oauth2.GoogleIdToken;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdTokenVerifier;
import com.google.api.client.googleapis.javanet.GoogleNetHttpTransport;
import com.google.api.client.json.gson.GsonFactory;
import java.io.IOException;
import java.security.GeneralSecurityException;
import java.util.Collections;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
@Slf4j
public class GoogleAuthService {
  @Value("${oauth2.google.client-id}")
  private String clientId;

  public GoogleIdToken verifyIdToken(String idTokenString)
      throws GeneralSecurityException, IOException {
    log.info("Verifying idToken={}", idTokenString);

    GoogleIdTokenVerifier verifier =
        new GoogleIdTokenVerifier.Builder(
                GoogleNetHttpTransport.newTrustedTransport(), GsonFactory.getDefaultInstance())
            .setAudience(Collections.singletonList(clientId))
            .build();

    return verifier.verify(idTokenString);
  }
}
