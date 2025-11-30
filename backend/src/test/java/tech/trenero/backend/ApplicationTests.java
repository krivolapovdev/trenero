package tech.trenero.backend;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.context.SpringBootTest.WebEnvironment;
import org.springframework.modulith.core.ApplicationModules;

@SpringBootTest(webEnvironment = WebEnvironment.RANDOM_PORT)
class ApplicationTests {
  @Test
  void shouldPassModuleVerification() {
    ApplicationModules modules = ApplicationModules.of(Application.class);
    modules.verify();
  }
}
