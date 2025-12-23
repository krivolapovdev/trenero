package tech.trenero.backend.common.config;

import graphql.scalars.ExtendedScalars;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.graphql.execution.RuntimeWiringConfigurer;

@Configuration
public class GraphQlConfig {
  @Bean
  public RuntimeWiringConfigurer runtimeWiringConfigurer() {
    return wiringBuilder ->
        wiringBuilder
            .scalar(ExtendedScalars.Date)
            .scalar(ExtendedScalars.DateTime)
            .scalar(ExtendedScalars.Time)
            .scalar(ExtendedScalars.LocalTime)
            .scalar(ExtendedScalars.UUID)
            .scalar(ExtendedScalars.GraphQLBigInteger)
            .scalar(ExtendedScalars.GraphQLBigDecimal);
  }
}
