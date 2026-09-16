package org.trenero.backend.auth.internal.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Configuration;

@Configuration
@ConfigurationProperties(prefix = "app.reviewer")
@Data
public class ReviewerProperties {
  private String key;
}
