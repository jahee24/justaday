//src/main/java/io/github/jahee24/justaday/entity/User.java
package io.github.jahee24.justaday.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "users") // PostgreSQL 예약어 충돌을 피하기 위해 'users' 사용
@Getter // @Data 대신 사용
@Setter // @Data 대신 사용
@NoArgsConstructor // JPA 사용을 위한 기본 생성자
@AllArgsConstructor
public class User {

    // 1. 내부 시스템용 PK (JPA 표준 및 DB 효율성)
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY) // PostgreSQL의 AUTO_INCREMENT 사용
    private Long id;

    // 2. 사용자 로그인 ID (Business Key)
    @Column(unique = true, nullable = false, length = 50)
    private String userId;

    // 2.1 Name 필드 추가 (Flutter에서 한 번 설정 후 변경 불가)
    @Column(nullable = true, length = 50)
    private String name;

    // 3. 보안 필드
    @Column(nullable = false, length = 100)
    private String passwordHash; // BCrypt 해시 저장 (100자 이상 확보)

    // 4. AI 설정 필드
    @Column(nullable = false)
    private int aiPersonaId; // 1:미르, 2:알파, 3:오든

    // 5. AI 메모리 필드 (장기 기록)
    @Column(columnDefinition = "integer default 0")
    private int totalFeedbackCount; // 총 피드백 횟수 (N번째 노력 지표)

    @Column(columnDefinition = "TEXT") // TEXT 타입으로 충분한 공간 확보
    private String habitHistorySummary; // AI가 요약한 장기 노력 기록 (주 1회 업데이트)

    @Column(nullable = true)
    private LocalDate lastSummaryUpdatedDate; // 장기 기억(HabitHistorySummary) 최종 업데이트 날짜

    // 생성 시간 필드 추가 (운영 및 감사 로그용)
    @CreationTimestamp
    private LocalDateTime createdAt;


    // Note: @AllArgsConstructor는 필요한 경우에만 추가합니다.
}
