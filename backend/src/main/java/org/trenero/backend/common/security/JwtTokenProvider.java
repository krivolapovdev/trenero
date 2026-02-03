package org.trenero.backend.common.security;

import io.jsonwebtoken.JwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import jakarta.annotation.PostConstruct;
import java.nio.charset.StandardCharsets;
import java.util.Base64;
import java.util.Date;
import java.util.UUID;
import javax.crypto.SecretKey;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;
import org.trenero.backend.common.config.JwtProperties;

@Component
@RequiredArgsConstructor
public class JwtTokenProvider {
  public static final String TOKEN_CLAIM_EMAIL = "email";

  private final JwtProperties jwtProperties;

  private SecretKey secretKey;

  @PostConstruct
  public void init() {
    byte[] bytes = jwtProperties.getSecretKey().getBytes();
    String secret = Base64.getEncoder().encodeToString(bytes);
    this.secretKey = Keys.hmacShaKeyFor(secret.getBytes(StandardCharsets.UTF_8));
  }

  public String generateAccessToken(JwtUser jwtUser) {
    long accessTokenExpirationMillis = jwtProperties.getAccessTokenExpiration().toMillis();
    Date expiration = new Date(System.currentTimeMillis() + accessTokenExpirationMillis);
    return Jwts.builder()
        .subject(jwtUser.userId().toString())
        .claim(TOKEN_CLAIM_EMAIL, jwtUser.email())
        .expiration(expiration)
        .issuedAt(new Date())
        .signWith(secretKey)
        .compact();
  }

  public String generateRefreshToken(JwtUser jwtUser) {
    long refreshTokenExpirationMillis = jwtProperties.getRefreshTokenExpiration().toMillis();
    Date expiration = new Date(System.currentTimeMillis() + refreshTokenExpirationMillis);
    return Jwts.builder()
        .subject(jwtUser.userId().toString())
        .claim(TOKEN_CLAIM_EMAIL, jwtUser.email())
        .expiration(expiration)
        .issuedAt(new Date())
        .signWith(secretKey)
        .compact();
  }

  public JwtUser extractUser(String token) {
    var claims = Jwts.parser().verifyWith(secretKey).build().parseSignedClaims(token).getPayload();

    UUID userId = UUID.fromString(claims.getSubject());
    String email = claims.get(TOKEN_CLAIM_EMAIL, String.class);

    return new JwtUser(userId, email);
  }

  public boolean isTokenValid(String token) {
    try {
      Jwts.parser().verifyWith(secretKey).build().parseSignedClaims(token);
      return true;
    } catch (JwtException | IllegalArgumentException ignored) {
      return false;
    }
  }
}
