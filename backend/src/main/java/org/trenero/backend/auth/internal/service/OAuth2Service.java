package org.trenero.backend.auth.internal.service;

import static org.trenero.backend.common.domain.OAuth2Provider.GOOGLE;

import lombok.NonNull;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Lazy;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.stereotype.Service;
import org.trenero.backend.auth.internal.request.OAuth2LoginRequest;
import org.trenero.backend.common.response.LoginResponse;
import org.trenero.backend.common.security.JwtUser;
import org.trenero.backend.user.external.UserSpi;

@Service
@RequiredArgsConstructor
@Slf4j
public class OAuth2Service {

  private final GoogleAuthService googleAuthService;
  private final JwtTokenService jwtTokenService;
  @Lazy private final UserSpi userSpi;

  public @NonNull LoginResponse googleLogin(@NonNull OAuth2LoginRequest request) {
    log.info("Processing Google OAuth2 login request");

    var googleIdToken =
        googleAuthService
            .verifyIdToken(request.token())
            .orElseThrow(() -> new BadCredentialsException("Invalid or expired Google ID token"));

    var payload = googleIdToken.getPayload();
    var providerId = payload.getSubject();
    var email = payload.getEmail();

    var user = userSpi.getOrCreateUserFromOAuth2(GOOGLE, providerId, email);
    var jwtUser = new JwtUser(user.id(), user.email());
    var tokens = jwtTokenService.createAccessAndRefreshTokens(jwtUser);

    return new LoginResponse(user, tokens);
  }

  public @NonNull LoginResponse appleLogin(@NonNull OAuth2LoginRequest ignoredRequest) {
    log.info("Processing Apple OAuth2 login request");
    throw new UnsupportedOperationException("Apple login is not yet implemented");
  }
}
