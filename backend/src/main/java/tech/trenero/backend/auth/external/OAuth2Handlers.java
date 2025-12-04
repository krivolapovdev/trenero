package tech.trenero.backend.auth.external;

import org.springframework.security.oauth2.client.web.AuthorizationRequestRepository;
import org.springframework.security.oauth2.core.endpoint.OAuth2AuthorizationRequest;
import org.springframework.security.web.authentication.AuthenticationFailureHandler;
import org.springframework.security.web.authentication.AuthenticationSuccessHandler;

public interface OAuth2Handlers {
  AuthenticationSuccessHandler getSuccessHandler();

  AuthenticationFailureHandler getFailureHandler();

  AuthorizationRequestRepository<OAuth2AuthorizationRequest> getAuthorizationRequestRepository();
}
