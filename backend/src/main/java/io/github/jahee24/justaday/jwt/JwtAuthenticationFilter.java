//src/main/java/io/github/jahee24/justaday/config/jwt/JwtAuthenticationFilter.java
package io.github.jahee24.justaday.jwt;

import io.github.jahee24.justaday.service.CustomUserDetailsService;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.util.StringUtils;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;

@Slf4j
public class JwtAuthenticationFilter extends OncePerRequestFilter {
    private final JwtTokenProvider jwtTokenProvider;
    private final CustomUserDetailsService userDetailsService; // Custom UserDetailsService 구현 필요

    public JwtAuthenticationFilter(JwtTokenProvider jwtTokenProvider, CustomUserDetailsService userDetailsService) {
        this.jwtTokenProvider = jwtTokenProvider;
        this.userDetailsService = userDetailsService;
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
            throws ServletException, IOException {

        log.info("JWT Filter is executing.");
        String requestURI = request.getRequestURI();
        // ⚠️ SecurityConfig의 permitAll 경로와 일치시켜야 합니다.
        // '/api/v1/auth/'와 '/api/v1/log/error/message' 경로는 토큰 검사를 우회합니다.
        if (requestURI.startsWith("/api/v1/auth/") || requestURI.startsWith("/api/v1/log/error/message")) {
            log.debug("Skip JWT filtering for public endpoint: {}", requestURI);
            filterChain.doFilter(request, response);
            return; // 이 경로는 토큰 검사를 건너뛰고 바로 다음 필터로 이동
        }
        // 1. HTTP Header에서 Token 추출 ("Bearer [Token]")
        String token = resolveToken(request);

        // 2. Token 유효성 검증
        if (token != null && jwtTokenProvider.validateToken(token)) {
            // 3. Token에서 userId (Subject) 추출
            String userId = jwtTokenProvider.getUserId(token);

            // 4. 추출된 userId로 DB에서 UserDetails 로드
            UserDetails userDetails = userDetailsService.loadUserByUsername(userId);

            log.info("User Details: " + userDetails);
            log.info("User Details.getAuthorities: " + userDetails.getAuthorities());
            // 5. Security Context에 인증 정보 설정 (Authentication 객체 생성)
            Authentication authentication = new UsernamePasswordAuthenticationToken(
                    userDetails, null, userDetails.getAuthorities());

            SecurityContextHolder.getContext().setAuthentication(authentication);
        }

        log.info("JWT Filter has been executed.");
        // 다음 필터로 진행
        filterChain.doFilter(request, response);
    }

    // Header에서 Bearer Token을 추출하는 헬퍼 메서드
    private String resolveToken(HttpServletRequest request) {
        String bearerToken = request.getHeader("Authorization");
        log.debug("JwtAuthenticationFilter---: JWT token found: {}", bearerToken);

        if (StringUtils.hasText(bearerToken) && bearerToken.startsWith("Bearer ")) {
            log.debug("JwtAuthenticationFilter: JWT token found: {}", bearerToken);
            return bearerToken.substring(7); // "Bearer " 이후의 Token 값 반환
        }
        return null;
    }
}
