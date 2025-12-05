//src/main/java/io/github/jahee24/justaday/config/exception/JwtAccessDeniedHandler.java
//
package io.github.jahee24.justaday.config.exception;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.http.MediaType;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.web.access.AccessDeniedHandler;
import org.springframework.stereotype.Component;

import java.io.IOException;

// 403 Forbidden 처리 (권한 부족)
@Component
public class JwtAccessDeniedHandler implements AccessDeniedHandler {

    @Override
    public void handle(HttpServletRequest request, HttpServletResponse response, AccessDeniedException accessDeniedException)
            throws IOException, ServletException {

        // HTTP 상태 코드 설정: 403 Forbidden
        response.setStatus(HttpServletResponse.SC_FORBIDDEN);

        // Content Type 설정: JSON 반환 강제
        response.setContentType(MediaType.APPLICATION_JSON_VALUE);
        response.setCharacterEncoding("UTF-8");

        // 응답 메시지 설정
        String message = "접근 권한이 없습니다. (ROLE 부족)";

        // JSON 응답 작성
        String jsonResponse = String.format("{\"error\": \"%s\", \"message\": \"%s\"}",
                "Forbidden", message);

        response.getWriter().write(jsonResponse);
    }
}