package tech.trenero.backend.auth.internal.helper;

import jakarta.servlet.http.Cookie;
import java.time.Duration;
import lombok.NoArgsConstructor;
import org.apache.tomcat.util.http.Rfc6265CookieProcessor;

@NoArgsConstructor(access = lombok.AccessLevel.PRIVATE)
public class CookieHelper {
  public static final String REFRESH_TOKEN_COOKIE_NAME = "refresh_token";

  public static String generateCookie(String name, String value, Duration maxAge) {
    Cookie cookie = new Cookie(name, value);
    cookie.setHttpOnly(Boolean.TRUE);
    cookie.setSecure(Boolean.TRUE);
    cookie.setMaxAge((int) maxAge.toSeconds());
    cookie.setPath("/");
    Rfc6265CookieProcessor processor = new Rfc6265CookieProcessor();
    return processor.generateHeader(cookie, null);
  }
}
