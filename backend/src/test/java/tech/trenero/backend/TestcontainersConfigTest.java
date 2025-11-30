package tech.trenero.backend;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.data.jpa.test.autoconfigure.DataJpaTest;
import org.springframework.context.annotation.Import;
import org.testcontainers.postgresql.PostgreSQLContainer;

@DataJpaTest
@Import(TestcontainersConfig.class)
class TestcontainersConfigTest {
  @Autowired private PostgreSQLContainer postgres;

  @Test
  void shouldStartPostgresContainer() {
    assertThat(postgres.isRunning()).isTrue();
    System.out.println("JDBC URL: " + postgres.getJdbcUrl());
    System.out.println("Username: " + postgres.getUsername());
    System.out.println("Password: " + postgres.getPassword());
  }
}
