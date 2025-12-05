package io.github.jahee24.justaday.service;

import io.github.jahee24.justaday.dao.UserDAO;
import io.github.jahee24.justaday.dto.SignupRequest;
import io.github.jahee24.justaday.entity.User;
import io.github.jahee24.justaday.repository.UserRepository;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

// src/main/java/[...]/service/AuthService.java
@Service
@RequiredArgsConstructor
public class AuthServiceImpl {

    private final UserRepository userRepository;
    private final UserDAO userDAO;
    private final PasswordEncoder passwordEncoder;

    @Transactional
    public User signup(SignupRequest request) {
        // 1. ID 중복 확인
        if (userRepository.findByUserId(request.getUserId()).isPresent()) {
            throw new RuntimeException("이미 존재하는 사용자 ID입니다."); // Custom Exception 처리 필요
        }

        // 2. 비밀번호 해싱
        String hashedPassword = passwordEncoder.encode(request.getPassword());

        // 3. User Entity 생성 및 초기값 설정
        User user = new User();
        user.setUserId(request.getUserId());
        user.setPasswordHash(hashedPassword);
        user.setAiPersonaId(request.getAiPersonaId());
        user.setTotalFeedbackCount(0);
        user.setHabitHistorySummary(""); // 초기 장기 메모리 초기화

        // 4. DB 저장
        return userRepository.save(user);
    }
}