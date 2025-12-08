package tech.trenero.backend.common.helper;

import jakarta.servlet.http.HttpServletResponse;
import java.time.Duration;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpHeaders;
import org.springframework.stereotype.Component;
import tech.trenero.backend.common.response.AccessTokenResponse;
import tech.trenero.backend.common.security.JwtTokenProvider;
import tech.trenero.backend.common.security.JwtUser;

@Component
@RequiredArgsConstructor
public class TokenHelper {
  private final JwtTokenProvider jwtTokenProvider;

  public AccessTokenResponse createAccessAndRefreshTokens(
      JwtUser jwtUser, HttpServletResponse response) {
    String refreshToken = jwtTokenProvider.generateRefreshToken(jwtUser);

    int refreshTokenExpiryInSeconds =
        (int) (jwtTokenProvider.getRefreshTokenExpirationMillis() / 1000);

    String refreshTokenCookie =
        CookieHelper.generateCookie(
            CookieHelper.REFRESH_TOKEN_COOKIE_NAME,
            refreshToken,
            Duration.ofSeconds(refreshTokenExpiryInSeconds));

    response.addHeader(HttpHeaders.SET_COOKIE, refreshTokenCookie);

    String accessToken = jwtTokenProvider.generateAccessToken(jwtUser);

    return new AccessTokenResponse(accessToken);
  }
}
