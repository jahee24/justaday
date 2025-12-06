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
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
@RequestMapping("/api/v1/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    @GetMapping("/check-id")
    public ResponseEntity<Map<String, Boolean>> checkUsername(@RequestParam("userId") String userId) {
        boolean isAvailable = !authService.isUserIdExists(userId);
        return ResponseEntity.ok(Map.of("isAvailable", isAvailable));
    }

    @PostMapping("/signup")
    public ResponseEntity<?> signup(@Valid @RequestBody SignupRequest request) {
        try {
            authService.signup(request);
            return ResponseEntity.status(HttpStatus.CREATED).body(Map.of("message", "회원가입 성공"));
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(Map.of("error", e.getMessage()));
        }
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(@Valid @RequestBody LoginRequest request) {
        try {
            LoginResponse response = authService.login(request);
            return ResponseEntity.ok(response);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of("error", e.getMessage()));
        }
    }
}
