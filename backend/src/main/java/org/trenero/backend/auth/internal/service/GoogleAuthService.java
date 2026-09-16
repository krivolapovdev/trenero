package org.trenero.backend.auth.internal.service;

import com.google.api.client.googleapis.auth.oauth2.GoogleIdToken;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdTokenVerifier;
import java.util.Optional;
import lombok.NonNull;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
@Slf4j
public class GoogleAuthService {

  private final GoogleIdTokenVerifier verifier;

  public Optional<GoogleIdToken> verifyIdToken(@NonNull String token) {
    log.info("Attempting to verify Google ID token");

    try {
      var googleIdToken = verifier.verify(token);
      return Optional.ofNullable(googleIdToken);
    } catch (Exception e) {
      log.error("Failed to verify Google ID token", e);
      return Optional.empty();
    }
  }
}
