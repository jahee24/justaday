// src/main/java/io/github/jahee24/justaday/config/exception/JwtAuthenticationEntryPoint.java
package io.github.jahee24.justaday.config.exception;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.http.MediaType;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.web.AuthenticationEntryPoint;
import org.springframework.stereotype.Component;

import java.io.IOException;

// 401 Unauthorized 처리
@Component
public class JwtAuthenticationEntryPoint implements AuthenticationEntryPoint {
    @Override
    public void commence(HttpServletRequest request, HttpServletResponse response, AuthenticationException authException)
            throws IOException, ServletException {

        // HTTP 상태 코드 설정: 401 Unauthorized
        response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);

        // Content Type 설정: JSON 반환 강제
        response.setContentType(MediaType.APPLICATION_JSON_VALUE);
        response.setCharacterEncoding("UTF-8");

        // 응답 메시지 설정
        String message = "Token이 없거나 유효하지 않습니다. 다시 로그인 해주세요.";

        // JSON 응답 작성
        String jsonResponse = String.format("{\"error\": \"%s\", \"message\": \"%s\"}",
                "Unauthorized", message);

        response.getWriter().write(jsonResponse);
    }
}