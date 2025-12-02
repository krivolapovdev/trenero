package tech.trenero.backend.common.security;

import jakarta.annotation.PostConstruct;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.Base64;
import javax.crypto.SecretKey;
import lombok.RequiredArgsConstructor;
import org.apache.commons.lang3.SerializationUtils;
import org.springframework.http.HttpHeaders;
import org.springframework.security.oauth2.client.web.AuthorizationRequestRepository;
import org.springframework.security.oauth2.core.endpoint.OAuth2AuthorizationRequest;
import org.springframework.stereotype.Component;
import tech.trenero.backend.common.config.OAuth2Properties;
import tech.trenero.backend.common.helper.CookieHelper;
import tech.trenero.backend.common.helper.EncryptionHelper;

@Component
@RequiredArgsConstructor
public class OAuth2AuthorizationRequestRepository
    implements AuthorizationRequestRepository<OAuth2AuthorizationRequest> {
  private final OAuth2Properties oAuth2Properties;

  private SecretKey encryptionKey;

  @PostConstruct
  public void init() {
    byte[] salt = {0};
    char[] password = oAuth2Properties.getSecretKey().toCharArray();
    this.encryptionKey = EncryptionHelper.generateKey(password, salt);
  }

  @Override
  public void saveAuthorizationRequest(
      OAuth2AuthorizationRequest authorizationRequest,
      HttpServletRequest request,
      HttpServletResponse response) {
    if (authorizationRequest == null) {
      String expiredCookie = CookieHelper.generateExpiredCookie(CookieHelper.OAUTH_COOKIE_NAME);
      response.addHeader(HttpHeaders.SET_COOKIE, expiredCookie);
      return;
    }

    String cookie =
        CookieHelper.generateCookie(
            CookieHelper.OAUTH_COOKIE_NAME,
            encrypt(authorizationRequest),
            oAuth2Properties.getCookieExpiration());

    response.addHeader(HttpHeaders.SET_COOKIE, cookie);
  }

  @Override
  public OAuth2AuthorizationRequest loadAuthorizationRequest(HttpServletRequest request) {
    return retrieveCookie(request);
  }

  @Override
  public OAuth2AuthorizationRequest removeAuthorizationRequest(
      HttpServletRequest request, HttpServletResponse response) {
    return retrieveCookie(request);
  }

  private OAuth2AuthorizationRequest retrieveCookie(HttpServletRequest request) {
    return CookieHelper.retrieve(request.getCookies(), CookieHelper.OAUTH_COOKIE_NAME)
        .map(this::decrypt)
        .orElse(null);
  }

  private String encrypt(OAuth2AuthorizationRequest authorizationRequest) {
    byte[] bytes = SerializationUtils.serialize(authorizationRequest);
    byte[] encryptedBytes = EncryptionHelper.encrypt(encryptionKey, bytes);
    return Base64.getEncoder().encodeToString(encryptedBytes);
  }

  private OAuth2AuthorizationRequest decrypt(String encrypted) {
    byte[] encryptedBytes = Base64.getDecoder().decode(encrypted);
    byte[] bytes = EncryptionHelper.decrypt(encryptionKey, encryptedBytes);
    return SerializationUtils.deserialize(bytes);
  }
}
