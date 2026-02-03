package org.trenero.backend.auth.internal.controller;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.trenero.backend.auth.internal.request.OAuth2LoginRequest;
import org.trenero.backend.auth.internal.service.OAuth2Service;
import org.trenero.backend.common.response.LoginResponse;

@RestController
@RequestMapping("/api/v1/oauth2")
@RequiredArgsConstructor
@Validated
public class OAuth2Controller {
  private final OAuth2Service oAuth2Service;

  @PostMapping("/google")
  public LoginResponse googleLogin(@RequestBody @Valid OAuth2LoginRequest request) {
    return oAuth2Service.googleLogin(request);
  }

  @PostMapping("/apple")
  public LoginResponse appleLogin(@RequestBody @Valid OAuth2LoginRequest request) {
    return oAuth2Service.appleLogin(request);
  }
}
