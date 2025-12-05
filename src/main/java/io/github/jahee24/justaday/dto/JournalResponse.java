// src/main/java/io/github/jahee24/justaday/dto/JournalResponse.java
package io.github.jahee24.justaday.dto;

import lombok.Builder;
import lombok.Data;
import java.util.List;

@Data
@Builder
public class JournalResponse {
    private String mentText;        // AI의 주 피드백 멘트
    private List<String> miniPlans; // AI가 제안한 실천 계획
    private int responseCode;       // 상태 코드 (0: 성공, 1: DB 오류 등)
}