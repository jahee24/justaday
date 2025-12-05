//src/main/java/io/github/jahee24/justaday/service/AuthServiceImpl.java
package io.github.jahee24.justaday.service;

import io.github.jahee24.justaday.jwt.JwtTokenProvider;
import io.github.jahee24.justaday.dto.LoginRequest;
import io.github.jahee24.justaday.dto.LoginResponse;
import io.github.jahee24.justaday.dto.SignupRequest;
import io.github.jahee24.justaday.entity.User;
import io.github.jahee24.justaday.repository.UserRepository;
//import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;


@Service
@RequiredArgsConstructor
@Slf4j
public class AuthServiceImpl implements AuthService{

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtTokenProvider jwtTokenProvider;

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

    @Transactional(readOnly = true)
    public LoginResponse login(LoginRequest request) {

        // 1. 사용자 ID로 DB에서 User 정보 조회
        User user = userRepository.findByUserId(request.getUserId())
                .orElseThrow(() -> new RuntimeException("일치하는 사용자 ID가 없습니다.")); // 400 Bad Request 유도
        log.info("Hashed password: {}", request.getPassword());

        // 2. 비밀번호 검증 (BCrypt Hashing 비교)
        if (!passwordEncoder.matches(request.getPassword(), user.getPasswordHash())) {
            throw new RuntimeException("비밀번호가 일치하지 않습니다.");
        }

        // 3. 인증 성공 시, JWT Token 생성 (TTL 7일)
        String token = jwtTokenProvider.createToken(user.getUserId());

        // 4. Token과 User ID를 포함한 응답 객체 반환
        return new LoginResponse(token, user.getUserId());
    }
}