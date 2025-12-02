package tech.trenero.backend.common.security;

import io.jsonwebtoken.JwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import jakarta.annotation.PostConstruct;
import java.nio.charset.StandardCharsets;
import java.util.Base64;
import java.util.Date;
import javax.crypto.SecretKey;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;
import tech.trenero.backend.common.config.JwtProperties;

@Component
@RequiredArgsConstructor
public class JwtTokenProvider {
  public static final String ACCESS_TOKEN_JSON_NAME = "access-token";
  public static final String REFRESH_TOKEN_COOKIE_NAME = "refresh_token";

  private final JwtProperties jwtProperties;

  private SecretKey secretKey;

  @PostConstruct
  public void init() {
    byte[] bytes = jwtProperties.getSecretKey().getBytes();
    String secret = Base64.getEncoder().encodeToString(bytes);
    this.secretKey = Keys.hmacShaKeyFor(secret.getBytes(StandardCharsets.UTF_8));
  }

  public String generateAccessToken(String email) {
    Date expiration =
        new Date(System.currentTimeMillis() + jwtProperties.getAccessTokenExpiration().toMillis());
    return Jwts.builder()
        .subject(email)
        .expiration(expiration)
        .issuedAt(new Date())
        .signWith(secretKey)
        .compact();
  }

  public String generateRefreshToken(String email) {
    Date expiration = new Date(System.currentTimeMillis() + getRefreshTokenExpirationMillis());
    return Jwts.builder()
        .subject(email)
        .expiration(expiration)
        .issuedAt(new Date())
        .signWith(secretKey)
        .compact();
  }

  public String extractEmail(String token) {
    return Jwts.parser()
        .verifyWith(secretKey)
        .build()
        .parseSignedClaims(token)
        .getPayload()
        .getSubject();
  }

  public boolean isTokenValid(String token) {
    try {
      Jwts.parser().verifyWith(secretKey).build().parseSignedClaims(token);
      return true;
    } catch (JwtException | IllegalArgumentException _) {
      return false;
    }
  }

  public long getRefreshTokenExpirationMillis() {
    return jwtProperties.getRefreshTokenExpiration().toMillis();
  }
}
