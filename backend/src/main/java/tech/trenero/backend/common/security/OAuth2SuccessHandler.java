package tech.trenero.backend.common.security;

import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.time.Duration;
import java.util.Map;
import lombok.RequiredArgsConstructor;
import org.jspecify.annotations.NonNull;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.security.core.Authentication;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.security.web.authentication.AuthenticationSuccessHandler;
import org.springframework.stereotype.Component;
import tech.trenero.backend.common.helper.CookieHelper;

@Component
@RequiredArgsConstructor
public class OAuth2SuccessHandler implements AuthenticationSuccessHandler {
  private final JwtTokenProvider jwtTokenProvider;
  private final ObjectMapper objectMapper;

  @Override
  public void onAuthenticationSuccess(
      @NonNull HttpServletRequest request,
      @NonNull HttpServletResponse response,
      @NonNull Authentication authentication)
      throws IOException {
    String expiredOauthCookie = CookieHelper.generateExpiredCookie(CookieHelper.OAUTH_COOKIE_NAME);
    response.addHeader(HttpHeaders.SET_COOKIE, expiredOauthCookie);

    String expiredRefreshTokenCookie =
        CookieHelper.generateExpiredCookie(JwtTokenProvider.REFRESH_TOKEN_COOKIE_NAME);
    response.addHeader(HttpHeaders.SET_COOKIE, expiredRefreshTokenCookie);

    OAuth2User oAuth2User = (OAuth2User) authentication.getPrincipal();
    if (oAuth2User == null) {
      response.sendError(HttpServletResponse.SC_BAD_REQUEST, "OAuth2 user not found");
      return;
    }

    String email = oAuth2User.getAttribute("email");
    if (email == null || email.isEmpty()) {
      response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Email not found in OAuth2User");
      return;
    }

    String refreshToken = jwtTokenProvider.generateRefreshToken(email);
    int refreshTokenExpiryInSeconds =
        (int) (jwtTokenProvider.getRefreshTokenExpirationMillis() / 1000);
    String refreshTokenCookie =
        CookieHelper.generateCookie(
            JwtTokenProvider.REFRESH_TOKEN_COOKIE_NAME,
            refreshToken,
            Duration.ofSeconds(refreshTokenExpiryInSeconds));
    response.addHeader(HttpHeaders.SET_COOKIE, refreshTokenCookie);

    String accessToken = jwtTokenProvider.generateAccessToken(email);
    response.setContentType(MediaType.APPLICATION_JSON_VALUE);
    response.setCharacterEncoding("UTF-8");
    Map<String, String> accessTokenResponse =
        Map.of(JwtTokenProvider.ACCESS_TOKEN_JSON_NAME, accessToken);
    objectMapper.writeValue(response.getWriter(), accessTokenResponse);
  }
}
