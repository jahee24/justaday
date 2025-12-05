// src/main/java/io/github/jahee24/justaday/service/AIPipelineServiceImpl.java

package io.github.jahee24.justaday.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import io.github.jahee24.justaday.dto.JournalResponse;
import io.github.jahee24.justaday.entity.AIFeedback;
import io.github.jahee24.justaday.entity.JournalLog;
import io.github.jahee24.justaday.repository.AIFeedbackRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Async; // ★ Import
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional; // Spring Transaction

import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@Service
@RequiredArgsConstructor
@Slf4j
public class AIPipelineServiceImpl implements AIPipelineService {

    private final AIFeedbackRepository aiFeedbackRepository;
    private final GeminiClientService geminiClientService;
    private final ObjectMapper objectMapper;

    @Async("aiTaskExecutor")  // 비동기 실행
    @Transactional(propagation = Propagation.REQUIRES_NEW) // 새 트랜잭션에서 DB 저장
    public void generateAndSaveFeedback(String prompt, JournalLog savedLog) {
        long startTime = System.currentTimeMillis();
        log.debug("⏳ [ASYNC START] Log ID: {}, Thread: {}", savedLog.getId(), Thread.currentThread().getName());
        try {
            String rawText = geminiClientService.generateContent(prompt).block().getGeneratedText();
            if (rawText == null || rawText.isEmpty()) {
                throw new IllegalStateException("Gemini API returned empty response");
            }
            JournalResponse response = parseGeminiResponse(rawText);

            // 2. AIFeedback 저장
            AIFeedback feedback = new AIFeedback();
            feedback.setJournal(savedLog); // 양방향 설정 완료
            feedback.setMentText(response.getMentText());
            feedback.setMiniPlansJson(objectMapper.writeValueAsString(response.getMiniPlans()));

            aiFeedbackRepository.save(feedback);

            long duration = System.currentTimeMillis() - startTime;
            log.info("✅ [ASYNC SUCCESS] Log ID: {}, Duration: {}ms, Thread: {}", savedLog.getId(), duration, Thread.currentThread().getName());

        }catch (Exception e) {
            long duration = System.currentTimeMillis() - startTime;
            log.error("❌ [ASYNC ERROR] Log ID: {}, Duration: {}ms, Error: {}, Thread: {}", savedLog.getId(), duration, e.getMessage(), Thread.currentThread().getName(), e);
            // TODO: 실패 로그 기록 또는 사용자에게 알림 로직 추가
        }
    }




    // AI 응답(JSON 문자열)을 JournalResponse DTO로 파싱
    public JournalResponse parseGeminiResponse(String rawText) {
        try {
            // AI가 간혹 JSON을 ```json ... ```으로 감싸는 경우를 대비하여 추출
            Matcher matcher = Pattern.compile("\\{.*\\}", Pattern.DOTALL).matcher(rawText);
            String jsonContent = matcher.find() ? matcher.group(0) : rawText;

            // JSON을 JournalResponse로 변환
            return objectMapper.readValue(jsonContent, new TypeReference<JournalResponse>() {
            });
        } catch (Exception e) {
            System.err.println("Failed to parse AI response: " + e.getMessage());
            return JournalResponse.builder()
                    .mentText("AI 코치 연결에 실패했습니다. 잠시 후 다시 시도해 주세요.")
                    .miniPlans(List.of())
                    .responseCode(1)
                    .build();
        }
    }


}