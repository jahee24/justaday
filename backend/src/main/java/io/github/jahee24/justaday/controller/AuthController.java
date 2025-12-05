// src/main/java/io/github/jahee24/justaday/controller/AuthController.java

package io.github.jahee24.justaday.controller;

import io.github.jahee24.justaday.dto.LoginRequest;
import io.github.jahee24.justaday.dto.LoginResponse;
import io.github.jahee24.justaday.dto.SignupRequest;
import io.github.jahee24.justaday.service.AuthService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
@RequestMapping("/api/v1/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    @PostMapping("/signup")
    public ResponseEntity<?> signup(@Valid @RequestBody SignupRequest request) {
        try {
            authService.signup(request);
            // 성공 응답 (201 Created)
            return ResponseEntity.status(HttpStatus.CREATED).body(Map.of("message", "회원가입 성공"));
        } catch (RuntimeException e) {
            // 중복 ID 오류 등 처리 (400 Bad Request)
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(Map.of("error", e.getMessage()));
        }
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(@Valid @RequestBody LoginRequest request) {
        try {
            // 1. Service의 login 로직 호출 (인증 및 Token 발행)
            LoginResponse response = authService.login(request);

            // 2. 성공 응답 (Token 포함)
            return ResponseEntity.ok(response);

        } catch (RuntimeException e) {
            // ID 없음, 비밀번호 불일치 등 RuntimeException 처리
            // 실제 운영에서는 'ID/PW가 일치하지 않습니다'와 같은 일반적인 메시지를 사용해야 보안에 유리합니다.
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of("error", e.getMessage()));
        }
    }}