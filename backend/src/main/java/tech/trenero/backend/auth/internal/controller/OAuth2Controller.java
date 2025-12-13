package tech.trenero.backend.auth.internal.controller;

import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;
import tech.trenero.backend.auth.internal.request.OAuth2IdTokenRequest;
import tech.trenero.backend.auth.internal.response.AuthResponse;
import tech.trenero.backend.auth.internal.service.OAuth2Service;

@RestController
@RequestMapping("/api/v1/oauth2")
@RequiredArgsConstructor
@Validated
public class OAuth2Controller {
  private final OAuth2Service oAuth2Service;

  @PostMapping("/google")
  public AuthResponse googleLogin(
      @RequestBody OAuth2IdTokenRequest request, HttpServletResponse servletResponse) {
    return oAuth2Service.googleLogin(request, servletResponse);
  }

  @PostMapping("/apple")
  public AuthResponse appleLogin(
      @RequestBody OAuth2IdTokenRequest request, HttpServletResponse servletResponse) {
    return oAuth2Service.appleLogin(request, servletResponse);
  }

  @PostMapping("/logout")
  @ResponseStatus(HttpStatus.NO_CONTENT)
  public void logout(HttpServletResponse servletResponse) {
    oAuth2Service.logout(servletResponse);
  }
}
