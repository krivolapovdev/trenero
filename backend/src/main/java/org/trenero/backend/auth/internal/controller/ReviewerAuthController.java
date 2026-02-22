package org.trenero.backend.auth.internal.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.trenero.backend.auth.internal.service.OAuth2Service;
import org.trenero.backend.common.response.LoginResponse;

@RestController
@RequestMapping("/auth/reviewer")
@RequiredArgsConstructor
public class ReviewerAuthController {
  private final OAuth2Service oAuth2Service;

  @PostMapping("/login")
  public LoginResponse login() {
    return oAuth2Service.loginAsReviewer();
  }
}
