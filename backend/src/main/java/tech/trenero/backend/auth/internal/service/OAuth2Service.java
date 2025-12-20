package tech.trenero.backend.auth.internal.service;

import static tech.trenero.backend.common.enums.OAuth2Provider.GOOGLE;

import com.google.api.client.googleapis.auth.oauth2.GoogleIdToken;
import lombok.RequiredArgsConstructor;
import lombok.SneakyThrows;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Lazy;
import org.springframework.stereotype.Service;
import tech.trenero.backend.auth.internal.request.OAuth2IdTokenRequest;
import tech.trenero.backend.auth.internal.response.AuthResponse;
import tech.trenero.backend.common.response.UserResponse;
import tech.trenero.backend.common.security.JwtUser;
import tech.trenero.backend.user.external.UserSpi;

@Service
@RequiredArgsConstructor
@Slf4j
public class OAuth2Service {
  private final GoogleAuthService googleAuthService;
  private final JwtTokenService jwtTokenService;
  @Lazy private final UserSpi userSpi;

  @SneakyThrows
  public AuthResponse googleLogin(OAuth2IdTokenRequest request) {
    log.info("Google login request: {}", request);

    GoogleIdToken googleIdToken = googleAuthService.verifyIdToken(request.idToken());

    if (googleIdToken == null) {
      throw new IllegalArgumentException("Invalid ID token");
    }

    GoogleIdToken.Payload payload = googleIdToken.getPayload();
    String providerId = payload.getSubject();
    String email = payload.getEmail();

    UserResponse userResponse = userSpi.getOrCreateUserFromOAuth2(email, GOOGLE, providerId);

    var jwtUser = new JwtUser(userResponse.id(), email);
    var accessTokenResponse = jwtTokenService.createAccessAndRefreshTokens(jwtUser);

    return new AuthResponse(userResponse, accessTokenResponse);
  }

  public AuthResponse appleLogin(OAuth2IdTokenRequest request) {
    log.info("Apple login request: {}", request);
    return null;
  }
}
