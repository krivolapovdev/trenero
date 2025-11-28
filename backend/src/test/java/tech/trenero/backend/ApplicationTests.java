package tech.trenero.backend;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.modulith.core.ApplicationModules;
import org.springframework.test.context.ActiveProfiles;

@SpringBootTest
@ActiveProfiles("test")
class ApplicationTests {
  @Test
  void shouldPassModuleVerification() {
    ApplicationModules modules = ApplicationModules.of(Application.class);
    modules.verify();
  }
}
