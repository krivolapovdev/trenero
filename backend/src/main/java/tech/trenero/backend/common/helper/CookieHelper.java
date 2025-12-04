package tech.trenero.backend.common.helper;

import static java.util.Objects.isNull;

import jakarta.servlet.http.Cookie;
import java.time.Duration;
import java.util.Arrays;
import java.util.Optional;
import lombok.NoArgsConstructor;
import org.apache.tomcat.util.http.Rfc6265CookieProcessor;

@NoArgsConstructor(access = lombok.AccessLevel.PRIVATE)
public class CookieHelper {
  public static final String OAUTH_COOKIE_NAME = "oauth";
  public static final String REFRESH_TOKEN_COOKIE_NAME = "refresh_token";

  public static Optional<String> retrieve(Cookie[] cookies, String name) {
    if (isNull(cookies)) {
      return Optional.empty();
    }

    return Arrays.stream(cookies)
        .filter(cookie -> cookie.getName().equalsIgnoreCase(name))
        .findAny()
        .map(Cookie::getValue);
  }

  public static String generateCookie(String name, String value, Duration maxAge) {
    Cookie cookie = new Cookie(name, value);
    cookie.setHttpOnly(Boolean.TRUE);
    cookie.setSecure(Boolean.TRUE);
    cookie.setMaxAge((int) maxAge.toSeconds());
    cookie.setPath("/");
    Rfc6265CookieProcessor processor = new Rfc6265CookieProcessor();
    return processor.generateHeader(cookie, null);
  }

  public static String generateExpiredCookie(String name) {
    return generateCookie(name, "-", Duration.ZERO);
  }
}
