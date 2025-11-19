package com.bezkoder.spring.jpa.postgresql.config; // Upewnij się, że pakiet pasuje

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.oauth2.jwt.JwtDecoders;

@Configuration
public class SecurityConfig {

    @Value("${aws.region}")
    private String region;

    @Value("${aws.cognito.user-pool-id}")
    private String userPoolId;

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        String issuerUri = String.format("https://cognito-idp.%s.amazonaws.com/%s", region, userPoolId);

        http
            .csrf(csrf -> csrf.disable())
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/api/**").authenticated()
                .anyRequest().permitAll()
            )
            .oauth2ResourceServer(oauth2 -> oauth2
                .jwt(jwt -> jwt.decoder(JwtDecoders.fromIssuerLocation(issuerUri)))
            );

        return http.build();
    }
}