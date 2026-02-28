package org.trenero.backend.auth.internal.service;

import static org.trenero.backend.common.domain.OAuth2Provider.GOOGLE;

import com.google.api.client.googleapis.auth.oauth2.GoogleIdToken;
import java.util.Optional;
import lombok.NonNull;
import lombok.RequiredArgsConstructor;
import lombok.SneakyThrows;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Lazy;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;
import org.trenero.backend.auth.internal.request.OAuth2LoginRequest;
import org.trenero.backend.common.domain.OAuth2Provider;
import org.trenero.backend.common.response.JwtTokensResponse;
import org.trenero.backend.common.response.LoginResponse;
import org.trenero.backend.common.response.UserResponse;
import org.trenero.backend.common.security.JwtUser;
import org.trenero.backend.user.external.UserSpi;

@Service
@RequiredArgsConstructor
@Slf4j
public class OAuth2Service {
  private final GoogleAuthService googleAuthService;
  private final JwtTokenService jwtTokenService;
  @Lazy private final UserSpi userSpi;

  @Value("${reviewer.key}")
  private String reviewerKey;

  @SneakyThrows
  public LoginResponse googleLogin(@NonNull OAuth2LoginRequest request) {
    log.info("Processing Google login: request={}", request);

    Optional<GoogleIdToken> googleIdToken = googleAuthService.verifyIdToken(request.token());

    if (googleIdToken.isEmpty()) {
      throw new IllegalArgumentException("Invalid ID token");
    }

    GoogleIdToken.Payload payload = googleIdToken.get().getPayload();
    String providerId = payload.getSubject();
    String email = payload.getEmail();

    UserResponse user = userSpi.getOrCreateUserFromOAuth2(GOOGLE, providerId, email);

    JwtUser jwtUser = new JwtUser(user.id(), user.email());
    JwtTokensResponse tokens = jwtTokenService.createAccessAndRefreshTokens(jwtUser);

    return new LoginResponse(user, tokens);
  }

  public LoginResponse appleLogin(@NonNull OAuth2LoginRequest request) {
    log.info("Processing Apple login: request={}", request);
    return null;
  }

  public LoginResponse loginAsReviewer(@NonNull String incomingKey) {
    log.info("Logging in as reviewer");

    if (!reviewerKey.equals(incomingKey)) {
      throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Invalid reviewer key");
    }

    var user =
        userSpi.getOrCreateUserFromOAuth2(
            OAuth2Provider.GOOGLE, "REVIEWER", "REVIEWER@TRENERO.ORG");

    var jwtUser = new JwtUser(user.id(), user.email());
    var tokens = jwtTokenService.createAccessAndRefreshTokens(jwtUser);

    return new LoginResponse(user, tokens);
  }
}
