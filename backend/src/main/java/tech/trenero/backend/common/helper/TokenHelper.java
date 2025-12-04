package tech.trenero.backend.common.helper;

import jakarta.servlet.http.HttpServletResponse;
import java.time.Duration;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpHeaders;
import org.springframework.stereotype.Component;
import tech.trenero.backend.common.response.AccessTokenResponse;
import tech.trenero.backend.common.security.JwtTokenProvider;

@Component
@RequiredArgsConstructor
public class TokenHelper {
  private final JwtTokenProvider jwtTokenProvider;

  public AccessTokenResponse generateTokens(String email, HttpServletResponse response) {
    String refreshToken = jwtTokenProvider.generateRefreshToken(email);
    int refreshTokenExpiryInSeconds =
        (int) (jwtTokenProvider.getRefreshTokenExpirationMillis() / 1000);
    String refreshTokenCookie =
        CookieHelper.generateCookie(
            CookieHelper.REFRESH_TOKEN_COOKIE_NAME,
            refreshToken,
            Duration.ofSeconds(refreshTokenExpiryInSeconds));
    response.addHeader(HttpHeaders.SET_COOKIE, refreshTokenCookie);

    String accessToken = jwtTokenProvider.generateAccessToken(email);
    return new AccessTokenResponse(accessToken);
  }
}
