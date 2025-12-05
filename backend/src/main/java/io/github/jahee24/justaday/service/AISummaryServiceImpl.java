// src/main/java/io/github/jahee24/justaday/service/AISummaryServiceImpl.java
package io.github.jahee24.justaday.service;

import io.github.jahee24.justaday.entity.JournalLog;
import io.github.jahee24.justaday.entity.User;
import io.github.jahee24.justaday.repository.JournalLogRepository;
import io.github.jahee24.justaday.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;

@Service
@RequiredArgsConstructor

public class AISummaryServiceImpl implements AISummaryService {
    private final UserRepository userRepository;
    private final JournalLogRepository journalLogRepository;
    private final GeminiClientService geminiClientService;

    /**
     * 장기 기억 업데이트 로직을 실행하는 핵심 메서드
     *
     * @param userId 업데이트 대상 사용자 ID
     */
    @Transactional // 트랜잭션을 적용하여 User 엔티티의 갱신을 보장
    public void updateHabitHistorySummary(Long userId) {
        // 사용자 로드
        User user = userRepository.findById(userId).orElse(null); // 사용자가 없으면 종료
        if (user == null) return;

        // 업데이트 조건 확인 (7일 경과 확인)
        final LocalDate today = LocalDate.now();
        final LocalDate oneWeekAgo = today.minusDays(7);
        if (user.getLastSummaryUpdatedDate() != null && !user.getLastSummaryUpdatedDate().isBefore(oneWeekAgo)) {
            return;
        }

        // 3. 일주일간의 로그 데이터 조회 , 최초 실행 시 30일치 조회
        final LocalDate summaryBaseDate = user.getLastSummaryUpdatedDate() != null ? user.getLastSummaryUpdatedDate() : today.minusDays(30);
        List<JournalLog> weeklyLogs = journalLogRepository.findByUserAndJournalDateAfter(user, summaryBaseDate.minusDays(1));

        if (weeklyLogs.isEmpty()) {
            // 업데이트할 로그가 없으면 종료
            user.setLastSummaryUpdatedDate(today);
            return;
        }

        // 4. 장기 기억 업데이트 프롬프트 생성 및 AI 호출 (이전과 동일)
        String currentSummary = user.getHabitHistorySummary() != null ? user.getHabitHistorySummary() : "기록이 아직 없습니다.";
        String updatePrompt = createSummaryUpdatePrompt(currentSummary, weeklyLogs);

        try {
            // Blocking 호출
            String newSummary = geminiClientService.generateContent(updatePrompt).block().getGeneratedText().trim();

            // 5. User 엔티티 갱신
            user.setHabitHistorySummary(newSummary);
            user.setLastSummaryUpdatedDate(today); // 오늘 날짜로 업데이트 시점 갱신
            // @Transactional 덕분에 자동 반영 (Dirty Checking)

        } catch (Exception e) {
            System.err.println("사용자 ID " + userId + " 장기 기억 업데이트 중 오류 발생: " + e.getMessage());
        }
    }

    // 장기 기억 업데이트 프롬프트 생성
    private String createSummaryUpdatePrompt(String currentSummary, List<JournalLog> recentLogs) {
        // 1. 최근 로그 내용을 포맷팅
        StringBuilder logContents = new StringBuilder();
        for (JournalLog log : recentLogs) {
            logContents.append(String.format("- 날짜: %s\n- 내용: %s\n",
                    log.getJournalDate(),
                    log.getContent()));
        }

        // 2. 업데이트 요청 프롬프트
        return String.format("""
                당신은 사용자의 장기적인 습관 및 패턴을 요약하는 AI 시스템입니다.
                **[기존 장기 기억 요약]**
                ---
                %s
                ---
                
                **[최근 일주일간의 사용자 기록]**
                %s
                
                요청: 위의 '기존 장기 기억 요약'과 '최근 기록'을 종합하여 **사용자의 최신 습관과 변화 패턴을 반영한 새로운 요약**을 단락 하나로 작성하여 응답하세요. 
                응답은 **오직** 갱신된 요약 텍스트여야 하며, 다른 서론/결론/JSON 포맷은 포함하지 마세요.
                """, currentSummary, logContents.toString());
    }
}

