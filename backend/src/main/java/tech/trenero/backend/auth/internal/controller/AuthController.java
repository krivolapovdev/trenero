package tech.trenero.backend.auth.internal.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/auth")
@RequiredArgsConstructor
@Validated
public class AuthController {
  @GetMapping("/unsecured")
  public String unsecured() {
    return "Hello, unsecured";
  }

  @GetMapping("/secured")
  @PreAuthorize("isAuthenticated()")
  public String secured(@AuthenticationPrincipal String email) {
    return "Hello, " + email;
  }
}
