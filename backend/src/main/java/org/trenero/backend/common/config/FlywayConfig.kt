package org.trenero.backend.common.config

import org.springframework.boot.flyway.autoconfigure.FlywayMigrationStrategy
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.context.annotation.Profile

@Configuration
@Profile("dev")
class FlywayConfig {

  @Bean
  fun flywayMigrationStrategy(): FlywayMigrationStrategy {
    return FlywayMigrationStrategy { flyway ->
      flyway.repair()
      flyway.migrate()
    }
  }
}
