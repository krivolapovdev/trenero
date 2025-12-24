package tech.trenero.backend.auth.internal.controller;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.graphql.data.method.annotation.Argument;
import org.springframework.graphql.data.method.annotation.MutationMapping;
import org.springframework.stereotype.Controller;
import org.springframework.validation.annotation.Validated;
import tech.trenero.backend.auth.internal.dto.LoginPayload;
import tech.trenero.backend.auth.internal.input.SocialLoginInput;
import tech.trenero.backend.auth.internal.service.OAuth2Service;

@Controller
@RequiredArgsConstructor
@Validated
public class OAuth2Controller {
  private final OAuth2Service oAuth2Service;

  @MutationMapping
  public LoginPayload googleLogin(@Argument("input") @Valid SocialLoginInput input) {
    return oAuth2Service.googleLogin(input);
  }

  @MutationMapping
  public LoginPayload appleLogin(@Argument("input") @Valid SocialLoginInput input) {
    return oAuth2Service.appleLogin(input);
  }
}
