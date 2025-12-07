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

    private String getCurrentUserId() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        return authentication.getName();
    }

    @GetMapping
    public ResponseEntity<UserResponse> getUserInfo() {
        String userId = getCurrentUserId();
        UserResponse response = userService.getUserInfo(userId);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/persona")
    public ResponseEntity<Void> updatePersona(@Valid @RequestBody PersonaUpdateRequest request) {
        String userId = getCurrentUserId();
        userService.updatePersona(userId, request);
        return ResponseEntity.ok().build();
    }

    @PostMapping("/name")
    public ResponseEntity<Void> updateUserName(@RequestBody Map<String, String> request) {
        String userId = getCurrentUserId();
        String name = request.get("name");
        userService.updateUserName(userId, name.trim());
        return ResponseEntity.ok().build();
    }

    @DeleteMapping
    public ResponseEntity<Void> deleteUser() {
        String userId = getCurrentUserId();
        userService.deleteUser(userId);
        return ResponseEntity.noContent().build();
    }
}
