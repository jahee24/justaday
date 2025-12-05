// src/main/java/io/github/jahee24/justaday/config/jwt/JwtTokenProvider.java
package io.github.jahee24.justaday.jwt;

import io.jsonwebtoken.*;
import io.jsonwebtoken.security.Keys;
import jakarta.annotation.PostConstruct;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import io.jsonwebtoken.io.Decoders; // Base64 디코딩을 위해 필요
import java.nio.charset.StandardCharsets;
import java.security.Key;
import java.util.Date;

@Component
@Slf4j
public class JwtTokenProvider {

    @Value("${jwt.secret}") // application.yml에서 secret 키 로드
    private String secretKey;

    @Value("${jwt.expiration-time}") // application.yml에서 만료 시간 로드
    private long expirationTime; // 밀리초 단위 (ms)

    private Key key; // Secret Key를 안전하게 처리할 Key 객체

    // 빈이 생성될 때 Secret Key를 Base64 디코딩하여 Key 객체로 초기화
    @PostConstruct
    protected void init() {
        byte[] keyBytes = Decoders.BASE64.decode(secretKey);
        this.key = Keys.hmacShaKeyFor(keyBytes);
    }

    // Token을 생성하는 핵심 메서드
    public String createToken(String userId) {
        Claims claims = Jwts.claims().setSubject(userId); // JWT Payload에 사용자 ID를 Subject로 저장
        Date now = new Date();
        Date validity = new Date(now.getTime() + expirationTime); // 현재 시간 + 만료 시간

        return Jwts.builder()
                .setClaims(claims) // 데이터 저장
                .setIssuedAt(now) // 토큰 발행 시간
                .setExpiration(validity) // 토큰 만료 시간
                .signWith(key, SignatureAlgorithm.HS256) // HS256 알고리즘과 Key로 서명
                .compact();
    }

    /**
     * Token에서 사용자 ID (Subject)를 추출합니다.
     */
    public String getUserId(String token) {
        return Jwts.parserBuilder()
                .setSigningKey(key)
                .build()
                .parseClaimsJws(token) // Token을 파싱하여 서명 검증
                .getBody()
                .getSubject(); // Subject(userId) 반환
    }

    /**
     * Token의 유효성 (서명 및 만료)을 검증합니다.
     */
    public boolean validateToken(String token) {
        try {
            Jwts.parserBuilder().setSigningKey(key).build().parseClaimsJws(token);
            return true;
        } catch (io.jsonwebtoken.security.SecurityException | MalformedJwtException e) {
            // 잘못된 JWT 서명
            log.warn("Invalid JWT signature: {}", e.getMessage()); // 로깅 필요
        } catch (ExpiredJwtException e) {
            // 만료된 JWT Token
            log.warn("Expired JWT token: {}", e.getMessage()); // 로깅 필요
        } catch (UnsupportedJwtException e) {
            // 지원되지 않는 JWT 형식
            log.warn("Unsupported JWT token: {}", e.getMessage());
        } catch (IllegalArgumentException e) {
            // JWT claims string is empty (토큰이 빈 경우)
            log.warn("JWT claims string is empty: {}", e.getMessage());
        }
        return false;
    }
}

// 주의: 위 validateToken 메서드가 정상 동작하려면 slf4j/Logback을 사용하기 위해
// 클래스 상단에 @Slf4j 어노테이션을 추가해야 합니다.}