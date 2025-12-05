// src/main/java/io/github/jahee24/justaday/service/UserServiceImpl.java
package io.github.jahee24.justaday.service;

import io.github.jahee24.justaday.dto.PersonaUpdateRequest;
import io.github.jahee24.justaday.dto.UserResponse;
import io.github.jahee24.justaday.entity.User;
import io.github.jahee24.justaday.repository.UserRepository;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class UserServiceImpl implements UserService {

    private final UserRepository userRepository;

    // 1. GET /api/v1/user 구현
    @Override
    public UserResponse getUserInfo(String userId) {
        User user = userRepository.findByUserId(userId)
                .orElseThrow(() -> new UsernameNotFoundException("User not found: " + userId));

        return UserResponse.fromEntity(user);
    }

    // 2. POST /api/v1/user/persona 구현
    @Override
    @Transactional
    public void updatePersona(String userId, PersonaUpdateRequest request) {
        User user = userRepository.findByUserId(userId)
                .orElseThrow(() -> new UsernameNotFoundException("User not found: " + userId));

        // 페르소나 ID 업데이트
        user.setAiPersonaId(request.getPersonaId());
        userRepository.save(user);
    }

    //  3. POST /api/v1/user/name 구현 (이름 설정)
    @Override
    @Transactional
    public void updateUserName(String userId, String name) {
        User user = userRepository.findByUserId(userId)
                .orElseThrow(() -> new UsernameNotFoundException("User not found: " + userId));

        boolean isAlreadySet = user.getName() != null && !user.getName().trim().isEmpty();

        if (isAlreadySet) {
            throw new RuntimeException("이름은 이미 설정되어 수정할 수 없습니다.");
        }
        user.setName(name);
        userRepository.save(user);
    }
}