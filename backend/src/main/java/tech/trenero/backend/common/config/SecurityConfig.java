package tech.trenero.backend.common.config;

import static org.springframework.security.config.Customizer.withDefaults;

import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import tech.trenero.backend.common.security.JwtAuthenticationFilter;
import tech.trenero.backend.common.security.OAuth2AuthorizationRequestRepository;
import tech.trenero.backend.common.security.OAuth2FailureHandler;
import tech.trenero.backend.common.security.OAuth2SuccessHandler;

@Configuration
@EnableMethodSecurity(securedEnabled = true, jsr250Enabled = true)
@RequiredArgsConstructor
public class SecurityConfig {
  private final JwtAuthenticationFilter jwtAuthenticationFilter;
  private final OAuth2SuccessHandler oAuth2SuccessHandler;
  private final OAuth2FailureHandler oAuth2FailureHandler;
  private final OAuth2AuthorizationRequestRepository oAuth2AuthorizationRequestRepository;

  @Bean
  public SecurityFilterChain securityFilterChain(HttpSecurity http) {
    return http.cors(withDefaults())
        .csrf(AbstractHttpConfigurer::disable)
        .sessionManagement(
            session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
        .oauth2Login(
            oauth2 ->
                oauth2
                    .authorizationEndpoint(
                        auth ->
                            auth.baseUri("/api/login/oauth2/authorization")
                                .authorizationRequestRepository(
                                    oAuth2AuthorizationRequestRepository))
                    .successHandler(oAuth2SuccessHandler)
                    .failureHandler(oAuth2FailureHandler))
        .addFilterBefore(jwtAuthenticationFilter, UsernamePasswordAuthenticationFilter.class)
        .build();
  }
}
