//backend/src/main/java/io/github/jahee24/justaday/controller/UserController.java
package io.github.jahee24.justaday.controller;

import io.github.jahee24.justaday.dto.PersonaUpdateRequest;
import io.github.jahee24.justaday.dto.UserResponse;
import io.github.jahee24.justaday.service.UserService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/v1/user")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    // Helper: Security Context에서 userId 추출
    private String getCurrentUserId() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        // JWT Filter에서 Authentication 객체를 CustomUserDetails (userId)로 설정했습니다.
        return authentication.getName();
    }

    // 1. GET /api/v1/user (Flutter 초기화면 분기용)
    @GetMapping
    public ResponseEntity<UserResponse> getUserInfo() {
        String userId = getCurrentUserId();
        UserResponse response = userService.getUserInfo(userId);
        return ResponseEntity.ok(response);
    }

    // 2. POST /api/v1/user/persona (페르소나 ID 설정/변경)
    @PostMapping("/persona")
    public ResponseEntity<Void> updatePersona(@Valid @RequestBody PersonaUpdateRequest request) {
        String userId = getCurrentUserId();
        userService.updatePersona(userId, request);
        return ResponseEntity.ok().build();
    }

    // 3. POST /api/v1/user/name (이름 설정 - Flutter의 _submitName 로직 대응)
    @PostMapping("/name")
    public ResponseEntity<Void> updateUserName(@RequestBody Map<String, String> request) {
        String userId = getCurrentUserId();
        String name = request.get("name");
        // Flutter는 raw String을 보내므로, @RequestBody String으로 받습니다.
        // 유효성 검사 등은 Service layer에서 처리합니다.
        userService.updateUserName(userId, name.trim());
        return ResponseEntity.ok().build();
    }
}