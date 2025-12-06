// src/main/java/io/github/jahee24/justaday/dto/JournalResponseDto.java
package io.github.jahee24.justaday.dto;

import io.github.jahee24.justaday.entity.AIFeedback;
import io.github.jahee24.justaday.entity.JournalLog;
import lombok.Builder;
import lombok.Data;

import java.time.LocalDate;
import java.util.List;

@Data
@Builder
public class JournalWithFeedbackResponseDTO {
    private Long id;
    private String content; // 저널 원문 (통합된 내용)
    private LocalDate journalDate;

    private String mentText;        // AI 피드백 멘트
    private List<String> miniPlans; // AI 미니 계획
    private int responseCode;       // 상태 코드 (성공 0)

    // Entity와 JSON String을 DTO로 변환하는 정적 메서드
    public static JournalWithFeedbackResponseDTO fromEntities(JournalLog log, AIFeedback feedback, List<String> miniPlans) {
        return JournalWithFeedbackResponseDTO.builder()
                .id(log.getId())
                .content(log.getContent())
                .journalDate(log.getJournalDate())
                .mentText(feedback.getMentText())
                .miniPlans(miniPlans)
                .responseCode(0) // 성공 시 0으로 고정
                .build();
    }
}