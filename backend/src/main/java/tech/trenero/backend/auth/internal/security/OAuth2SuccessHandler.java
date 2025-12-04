package tech.trenero.backend.auth.internal.security;

import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import lombok.RequiredArgsConstructor;
import org.jspecify.annotations.NonNull;
import org.springframework.http.HttpHeaders;
import org.springframework.security.core.Authentication;
import org.springframework.security.oauth2.client.authentication.OAuth2AuthenticationToken;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.security.web.authentication.AuthenticationSuccessHandler;
import org.springframework.stereotype.Component;
import tech.trenero.backend.auth.internal.client.UserClient;
import tech.trenero.backend.common.enums.OAuth2Provider;
import tech.trenero.backend.common.helper.CookieHelper;
import tech.trenero.backend.common.helper.TokenHelper;

@Component
@RequiredArgsConstructor
public class OAuth2SuccessHandler implements AuthenticationSuccessHandler {
  private final UserClient userClient;
  private final ObjectMapper objectMapper;
  private final TokenHelper tokenHelper;

  @Override
  public void onAuthenticationSuccess(
      @NonNull HttpServletRequest request,
      @NonNull HttpServletResponse response,
      @NonNull Authentication authentication)
      throws IOException {
    String expiredOauthCookie = CookieHelper.generateExpiredCookie(CookieHelper.OAUTH_COOKIE_NAME);
    response.addHeader(HttpHeaders.SET_COOKIE, expiredOauthCookie);

    String expiredRefreshTokenCookie =
        CookieHelper.generateExpiredCookie(CookieHelper.REFRESH_TOKEN_COOKIE_NAME);
    response.addHeader(HttpHeaders.SET_COOKIE, expiredRefreshTokenCookie);

    if (!(authentication instanceof OAuth2AuthenticationToken auth2AuthenticationToken)) {
      response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Authentication is not OAuth2");
      return;
    }

    OAuth2User oAuth2User = auth2AuthenticationToken.getPrincipal();
    if (oAuth2User == null) {
      response.sendError(HttpServletResponse.SC_BAD_REQUEST, "OAuth2 user not found");
      return;
    }

    String email = oAuth2User.getAttribute("email");
    String provider = auth2AuthenticationToken.getAuthorizedClientRegistrationId();
    OAuth2Provider oAuth2Provider = OAuth2Provider.valueOf(provider.toUpperCase());
    String providerId = oAuth2User.getAttribute("sub");
    userClient.getOrCreateUserFromOAuth(email, oAuth2Provider, providerId);

    var accessTokenResponse = tokenHelper.generateTokens(email, response);
    objectMapper.writeValue(response.getWriter(), accessTokenResponse);
  }
}
