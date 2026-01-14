package tech.trenero.backend;

import org.junit.jupiter.api.Test;
import org.springframework.modulith.core.ApplicationModules;

class ApplicationTests {
  @Test
  void shouldPassModuleVerification() {
    ApplicationModules modules = ApplicationModules.of(Application.class);
    modules.verify();
  }
}
