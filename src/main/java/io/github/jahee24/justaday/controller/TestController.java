// src/main/java/io/github/jahee24/justaday/controller/TestController.java
package io.github.jahee24.justaday.controller;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/log")
@RequiredArgsConstructor
@Slf4j
public class TestController {

    @GetMapping("/test")
    public ResponseEntity<String> getTestLog() {
        // 인증된 사용자 정보를 Security Context에서 가져옵니다.
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String userId = authentication.getName();

        // 이 로그가 콘솔에 찍히면 W2 JWT 인증은 완벽하게 성공한 것입니다.
        log.info("AUTH SUCCESS: Protected API accessed successfully by user: {}", userId);

        // 정상적인 200 OK 응답을 반환합니다.
        return ResponseEntity.ok("Auth success! User: " + userId + ". W2 Security system is complete.");
    }
    @PostMapping("/error/message")
    public void errorMessage(@RequestBody String message) {
        log.error("오류 발생 : "+message);
    }
}