//src/main/java/io/github/jahee24/justaday/config/SecurityConfig.java
package io.github.jahee24.justaday.config;

import io.github.jahee24.justaday.exception.JwtAccessDeniedHandler;
import io.github.jahee24.justaday.exception.JwtAuthenticationEntryPoint;
import io.github.jahee24.justaday.jwt.JwtAuthenticationFilter;
import io.github.jahee24.justaday.jwt.JwtTokenProvider;
import io.github.jahee24.justaday.service.CustomUserDetailsService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

@Configuration
@EnableWebSecurity
@Slf4j
@RequiredArgsConstructor // JwtTokenProvider와 UserDetailsService 주입을 위해 사용
public class SecurityConfig {
    private final JwtTokenProvider jwtTokenProvider;
    private final CustomUserDetailsService userDetailsService;
    private final JwtAuthenticationEntryPoint jwtAuthenticationEntryPoint;
    private final JwtAccessDeniedHandler jwtAccessDeniedHandler;
    @Bean
    /// password 단방향 암호화 적용
    public PasswordEncoder bCryptPasswordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        log.info("Security Filter Chain");
        log.debug("Security Filter Chain");

        http
                .csrf(AbstractHttpConfigurer::disable)
                .anonymous(AbstractHttpConfigurer::disable)
                .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                .authorizeHttpRequests(auth -> auth
                        .requestMatchers("/api/v1/auth/**","/api/v1/log/error/message/**").permitAll()
                        .anyRequest().authenticated()
                )
                // Exception Handler 등록 (인증/인가 실패 시 JSON 응답 처리)
                .exceptionHandling(handling -> handling
                        .accessDeniedHandler(jwtAccessDeniedHandler) // 403 Forbidden
                        .authenticationEntryPoint(jwtAuthenticationEntryPoint) // 401 Unauthorized
                )
                // JWT Filter를 UsernamePasswordAuthenticationFilter 이전에 추가 (가장 중요)
                .addFilterBefore(new JwtAuthenticationFilter(jwtTokenProvider, userDetailsService),
                        UsernamePasswordAuthenticationFilter.class);

        log.debug("Security Filter Chain55555");
        return http.build();
    }


}
