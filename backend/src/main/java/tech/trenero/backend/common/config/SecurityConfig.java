package tech.trenero.backend.common.config;

import static org.springframework.security.config.Customizer.withDefaults;

import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import tech.trenero.backend.auth.external.OAuth2Handlers;
import tech.trenero.backend.common.helper.CookieHelper;
import tech.trenero.backend.common.security.JwtAuthenticationFilter;

@Configuration
@EnableMethodSecurity(securedEnabled = true, jsr250Enabled = true)
@RequiredArgsConstructor
public class SecurityConfig {
  private final JwtAuthenticationFilter jwtAuthenticationFilter;
  private final OAuth2Handlers oAuth2Handlers;

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
                                    oAuth2Handlers.getAuthorizationRequestRepository()))
                    .successHandler(oAuth2Handlers.getSuccessHandler())
                    .failureHandler(oAuth2Handlers.getFailureHandler()))
        .logout(
            logout ->
                logout
                    .logoutUrl("/api/logout")
                    .deleteCookies(CookieHelper.REFRESH_TOKEN_COOKIE_NAME)
                    .logoutSuccessHandler(
                        (_, response, _) -> response.setStatus(HttpServletResponse.SC_OK)))
        .addFilterBefore(jwtAuthenticationFilter, UsernamePasswordAuthenticationFilter.class)
        .build();
  }
}
