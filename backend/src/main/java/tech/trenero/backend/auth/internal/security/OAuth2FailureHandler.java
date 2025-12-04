package tech.trenero.backend.auth.internal.security;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.jspecify.annotations.NonNull;
import org.springframework.http.HttpHeaders;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.web.authentication.AuthenticationFailureHandler;
import org.springframework.stereotype.Component;
import tech.trenero.backend.common.helper.CookieHelper;
import tech.trenero.backend.common.security.JwtTokenProvider;

@Component
public class OAuth2FailureHandler implements AuthenticationFailureHandler {
  @Override
  public void onAuthenticationFailure(
      @NonNull HttpServletRequest request,
      @NonNull HttpServletResponse response,
      @NonNull AuthenticationException exception) {
    String expiredOauthCookie = CookieHelper.generateExpiredCookie(CookieHelper.OAUTH_COOKIE_NAME);
    response.addHeader(HttpHeaders.SET_COOKIE, expiredOauthCookie);

    String expiredRefreshTokenCookie =
        CookieHelper.generateExpiredCookie(JwtTokenProvider.REFRESH_TOKEN_COOKIE_NAME);
    response.addHeader(HttpHeaders.SET_COOKIE, expiredRefreshTokenCookie);

    response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
  }
}
