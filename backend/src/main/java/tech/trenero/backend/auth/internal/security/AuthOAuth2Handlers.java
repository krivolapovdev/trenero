package tech.trenero.backend.auth.internal.security;

import lombok.RequiredArgsConstructor;
import org.springframework.security.oauth2.client.web.AuthorizationRequestRepository;
import org.springframework.security.oauth2.core.endpoint.OAuth2AuthorizationRequest;
import org.springframework.security.web.authentication.AuthenticationFailureHandler;
import org.springframework.security.web.authentication.AuthenticationSuccessHandler;
import org.springframework.stereotype.Component;
import tech.trenero.backend.auth.external.OAuth2Handlers;

@Component
@RequiredArgsConstructor
public class AuthOAuth2Handlers implements OAuth2Handlers {
  private final OAuth2SuccessHandler successHandler;
  private final OAuth2FailureHandler failureHandler;
  private final OAuth2AuthorizationRequestRepository authorizationRequestRepository;

  @Override
  public AuthenticationSuccessHandler getSuccessHandler() {
    return successHandler;
  }

  @Override
  public AuthenticationFailureHandler getFailureHandler() {
    return failureHandler;
  }

  @Override
  public AuthorizationRequestRepository<OAuth2AuthorizationRequest>
      getAuthorizationRequestRepository() {
    return authorizationRequestRepository;
  }
}
