package tech.trenero.backend.auth.internal.config;

import java.time.Duration;
import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Configuration;

@Configuration
@ConfigurationProperties(prefix = "oauth2")
@Data
public class OAuth2Properties {
  private String secretKey;
  private Duration cookieExpiration;
}
