//src/main/java/io/github/jahee24/justaday/service/AuthServiceImpl.java
package io.github.jahee24.justaday.service;

import io.github.jahee24.justaday.dto.LoginRequest;
import io.github.jahee24.justaday.dto.LoginResponse;
import io.github.jahee24.justaday.dto.SignupRequest;
import io.github.jahee24.justaday.entity.User;
import io.github.jahee24.justaday.jwt.JwtTokenProvider;
import io.github.jahee24.justaday.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.config.annotation.authentication.builders.AuthenticationManagerBuilder;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional
public class AuthServiceImpl implements AuthService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final AuthenticationManagerBuilder authenticationManagerBuilder;
    private final JwtTokenProvider jwtTokenProvider;

    @Override
    public void signup(SignupRequest request) {
        if (userRepository.existsByUserId(request.getUserId())) {
            throw new RuntimeException("이미 사용 중인 아이디입니다.");
        }
        User user = User.builder()
                .userId(request.getUserId())
                .passwordHash(passwordEncoder.encode(request.getPassword()))
                .aiPersonaId(request.getAiPersonaId())
                .build();
        userRepository.save(user);
    }

    @Override
    public LoginResponse login(LoginRequest request) {
        UsernamePasswordAuthenticationToken authenticationToken =
                new UsernamePasswordAuthenticationToken(request.getUserId(), request.getPassword());
        Authentication authentication = authenticationManagerBuilder.getObject().authenticate(authenticationToken);
        String token = jwtTokenProvider.createToken(authentication);
        return new LoginResponse(token, request.getUserId());
    }

    @Override
    public boolean isUserIdExists(String userId) {
        return userRepository.existsByUserId(userId);
    }
}
