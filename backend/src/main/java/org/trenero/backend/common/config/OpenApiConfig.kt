package org.trenero.backend.common.config

import io.swagger.v3.core.jackson.ModelResolver
import org.springframework.context.annotation.Configuration

@Configuration
class OpenApiConfig {
  companion object {
    init {
      ModelResolver.enumsAsRef = true
    }
  }
}
