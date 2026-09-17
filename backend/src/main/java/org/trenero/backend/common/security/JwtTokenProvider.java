package org.trenero.backend.common.security;

import io.jsonwebtoken.JwtException;
import io.jsonwebtoken.JwtParser;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import jakarta.annotation.PostConstruct;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.util.Date;
import java.util.UUID;
import javax.crypto.SecretKey;
import lombok.NonNull;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.trenero.backend.common.config.JwtProperties;
import org.trenero.backend.common.domain.TokenType;

@Component
@RequiredArgsConstructor
@Slf4j
public class JwtTokenProvider {

  public static final String TOKEN_CLAIM_EMAIL = "email";
  public static final String TOKEN_CLAIM_TYPE = "type";

  private final JwtProperties jwtProperties;

  private SecretKey secretKey;
  private JwtParser jwtParser;

  @PostConstruct
  public void init() {
    var keyBytes = jwtProperties.getSecretKey().getBytes(StandardCharsets.UTF_8);
    this.secretKey = Keys.hmacShaKeyFor(keyBytes);
    this.jwtParser = Jwts.parser().verifyWith(secretKey).build();
  }

  public @NonNull String generateAccessToken(@NonNull JwtUser jwtUser) {
    return generateToken(jwtUser, jwtProperties.getAccessTokenExpiration(), TokenType.ACCESS);
  }

  public @NonNull String generateRefreshToken(@NonNull JwtUser jwtUser) {
    return generateToken(jwtUser, jwtProperties.getRefreshTokenExpiration(), TokenType.REFRESH);
  }

  public @NonNull JwtUser extractUser(@NonNull String token) {
    var claims = jwtParser.parseSignedClaims(token).getPayload();

    var id = UUID.fromString(claims.getSubject());
    var email = claims.get(TOKEN_CLAIM_EMAIL, String.class);

    return new JwtUser(id, email);
  }

  public boolean isTokenValid(@NonNull String token, @NonNull TokenType expectedType) {
    try {
      var claims = jwtParser.parseSignedClaims(token).getPayload();
      var tokenTypeStr = claims.get(TOKEN_CLAIM_TYPE, String.class);
      return expectedType.name().equals(tokenTypeStr);
    } catch (JwtException | IllegalArgumentException e) {
      log.warn("JWT validation failed: {}", e.getMessage());
      return false;
    }
  }

  private String generateToken(JwtUser jwtUser, Duration expirationDuration, TokenType tokenType) {
    var now = new Date();
    var expiration = new Date(now.getTime() + expirationDuration.toMillis());

    return Jwts.builder()
        .subject(jwtUser.id().toString())
        .claim(TOKEN_CLAIM_EMAIL, jwtUser.email())
        .claim(TOKEN_CLAIM_TYPE, tokenType.name())
        .issuedAt(now)
        .expiration(expiration)
        .signWith(secretKey)
        .compact();
  }
}
