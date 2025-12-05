// src/main/java/io/github/jahee24/justaday/service/AILogServiceImpl.java
package io.github.jahee24.justaday.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import io.github.jahee24.justaday.constant.AIPersona;
import io.github.jahee24.justaday.dto.GeminiResponse;
import io.github.jahee24.justaday.dto.JournalRequest;
import io.github.jahee24.justaday.dto.JournalResponse;
import io.github.jahee24.justaday.dto.JournalResponseDto;
import io.github.jahee24.justaday.entity.AIFeedback;
import io.github.jahee24.justaday.entity.JournalLog;
import io.github.jahee24.justaday.entity.User;
import io.github.jahee24.justaday.repository.AIFeedbackRepository;
import io.github.jahee24.justaday.repository.JournalLogRepository;
import io.github.jahee24.justaday.repository.UserRepository;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Sort;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Mono;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
@Slf4j
public class AILogServiceImpl implements AILogService {

    private final JournalLogRepository journalLogRepository;
    private final AIFeedbackRepository aiFeedbackRepository;
    private final UserRepository userRepository;
    private final GeminiClientService geminiClientService;
    private final ObjectMapper objectMapper; // JSON 파싱을 위한 ObjectMapper 주입
    private final AIPipelineService aiPipelineService;

    // 저널 작성 및 AI 피드백 생성/저장 핵심 로직
    @Transactional
    public JournalResponse submitJournalAndGetFeedback(String userId, JournalRequest request) {
        long startTime = System.currentTimeMillis();
        log.info("📥 [SERVICE START] User: {}, Thread: {}", userId, Thread.currentThread().getName());

        LocalDate today = LocalDate.now();
        final LocalDate oneWeekAgo = today.minusDays(7);

        User user = userRepository.findByUserId(userId)
                .orElseThrow(() -> new UsernameNotFoundException("User not found: " + userId));

        if (journalLogRepository.findByUserIdAndJournalDate(user.getId(), today).isPresent()) {
            throw new IllegalStateException("하루에 한 번,만 저널을 작성할 수 있습니다.");
        }

        // JournalLog 저장 (DB 트랜잭션 시작)
        JournalLog logj = new JournalLog();
        logj.setUser(user);

        String unifiedContent = String.format("상태 레벨: %d\n행동: %s\n감정: %s\n상황(Context): %s",
                request.getStatus(),
                request.getJournalAction(),
                request.getJournalEmotion(),
                request.getJournalContext());
        logj.setContent(unifiedContent);
        logj.setJournalDate(today);
        JournalLog savedLog = journalLogRepository.save(logj);

        // 단기 기억용: 오늘을 제외한 최근 3개 로그 조회
        List<JournalLog> recentLogs = journalLogRepository.findTop3ByUserAndJournalDateBeforeOrderByJournalDateDesc(user, today);

        // AI 프롬프트 생성 (페르소나 ID, 이름, 저널 내용을 포함)
        String personaId = String.valueOf(user.getAiPersonaId());
        String name = user.getName();
        String userName = (name != null && !name.trim().isEmpty()) ? name : "사용자";
        String prompt = createGeminiPrompt(personaId, userName, unifiedContent, user.getHabitHistorySummary(), recentLogs);

        aiPipelineService.generateAndSaveFeedback(prompt, savedLog);
        long duration = System.currentTimeMillis() - startTime;
        log.info("📤 [SERVICE END] User: {}, Duration: {}ms (Async AI started)", userId, duration);

        // Gemini API 호출
        return JournalResponse.builder()
                .mentText("저널 기록 완료. AI 코치가 피드백을 준비 중입니다. 잠시 후 확인해 주세요.")
                .miniPlans(List.of())
                .responseCode(0)
                .build();
    }


    // 최근 저널 로그 1개 조회 로직 (log/latest)
    @Transactional
    public Optional<JournalResponseDto> findLatestJournalLog(String userId) {
        User user = userRepository.findByUserId(userId)
                .orElseThrow(() -> new UsernameNotFoundException("User not found: " + userId));

        // 1. 오늘 작성된 로그를 찾습니다. (가장 최신 로그가 아리나 오늘 로그만 확인)
        Optional<JournalLog> todayLogOptional = journalLogRepository.findByUserIdAndJournalDate(user.getId(), LocalDate.now());

        if (todayLogOptional.isEmpty()) {
            // 오늘 로그가 없으면 (저널 미작성 상태) -> Optional.empty() 반환
            return Optional.empty();
        }

        // 2. 피드백 누락 여부 확인 및 생성 후 DTO 반환
        JournalLog todayLog = todayLogOptional.get();
        return Optional.of(ensureFeedbackAndConvertToDto(todayLog, user));
    }


    // 전체 저널 로그 목록 조회 로직 (log/getall)
    @Transactional
    public List<JournalResponseDto> findAllJournalLogs(String userId) {
        User user = userRepository.findByUserId(userId)
                .orElseThrow(() -> new UsernameNotFoundException("User not found: " + userId));

        // OrderBy: journalDate 기준 내림차순 정렬
        List<JournalLog> allLogs = journalLogRepository.findByUser(user, Sort.by(Sort.Direction.DESC, "journalDate"));

        return allLogs.stream()
                // 분리된 ensureFeedbackAndConvertToDto 로직을 모든 로그에 적용
                .map(log -> {
                    // 피드백이 없는 로그도 이 메서드를 통해 재생성됩니다.
                    try {
                        return ensureFeedbackAndConvertToDto(log, user);
                    } catch (Exception e) {
                        System.err.println("Error processing log ID " + log.getId() + ": " + e.getMessage());
                        // 오류 발생 시 오류 메시지를 포함한 DTO 반환 (클라이언트에게 실패 알림)
                        return JournalResponseDto.builder()
                                .id(log.getId())
                                .content(log.getContent())
                                .journalDate(log.getJournalDate())
                                .mentText("데이터 처리 중 오류 발생: " + e.getMessage())
                                .miniPlans(List.of())
                                .responseCode(99)
                                .build();
                    }
                })
                .toList();
    }

    // Gemini에게 요청할 프롬프트 생성 로직
    private String createGeminiPrompt(String personaId, String userName, String journalContent, String habitSummary, List<JournalLog> recentLogs) {
        // 1. 페르소나 정보 로드
        int personaIdInt = Integer.parseInt(personaId);
        AIPersona persona = AIPersona.getPersonaById(personaIdInt); // Enum 페르소나

        // 단기 기억
        StringBuilder recentLogContent = new StringBuilder();
        if (!recentLogs.isEmpty()) {
            recentLogContent.append("\n\n**[최근 3일간의 사용자 기록 (단기 기억)]**\n");
            for (JournalLog log : recentLogs) {
                recentLogContent.append(String.format("날짜 %s: %s\n", log.getJournalDate(), log.getContent()));
            }
            recentLogContent.append("----------------------------\n");
        }
        //
        String summaryContent = habitSummary != null ? habitSummary : "아직 장기 기억 요약 정보가 없습니다. (최초 작성 중)";

        return String.format(
                """
                        당신은 AI 페르소나 ID %d (%s)의 역할을 수행합니다.
                                    **[당신의 역할]** %s
                        
                                    **[사용자의 장기 기억 요약]**
                                    %s
                        
                                    %s
                        
                                    사용자가 작성한 저널을 분석하여, 다음 JSON 형식에 맞춰 응답하세요.
                                    응답 JSON 형식: {"mentText": "주요 멘트", "miniPlans": ["계획1", "계획2", "계획3"]}
                        
                                    요청 조건:
                                    1. mentText: 사용자(%s)에게 **당신의 역할과 장기/단기 기억을 모두 반영**하여 피드백 본문을 작성하세요.
                                        **[길이 제약: 100자 이상 150자 이하의 친근하고 명확한 문장으로 작성]**
                                    2. miniPlans: 저널 내용 기반으로 실천할 수 있는 3가지 간단한 행동 계획을 제시하세요.
                                    3. 응답은 오직 JSON 객체(```json ... ``` 없이)여야 합니다.
                        
                                    **[오늘의 저널]**
                                    ---
                                    %s
                                    ---
                        """,
                persona.getId(),
                persona.getName(),
                persona.getRoleDescription(),
                summaryContent, // ★ 장기 기억 주입
                recentLogContent.toString(), // ★ 단기 기억 주입
                userName,
                journalContent);
    }


    // JSON String을 List<String>으로 변환
    private List<String> convertMiniPlansJsonToList(String jsonString) {
        try {
            return objectMapper.readValue(jsonString, new TypeReference<List<String>>() {
            });
        } catch (JsonProcessingException e) {
            System.err.println("MiniPlans JSON Parsing Error: " + e.getMessage());
            return List.of("미니 계획을 불러오는 데 실패했습니다.");
        }
    }

    /**
     * [분리된 로직] 피드백이 누락된 로그를 받아 AI 피드백을 생성/저장하고 DTO를 반환합니다.
     *
     * @param journalLog 피드백이 누락될 수 있는 JournalLog
     * @param user       해당 저널의 사용자
     * @return 피드백이 포함된 JournalResponseDto
     */
    private JournalResponseDto ensureFeedbackAndConvertToDto(JournalLog journalLog, User user) {
        AIFeedback feedback = journalLog.getAiFeedback();

        if (feedback != null) {
            // 이미 피드백이 있는 경우 (정상 경로)
            List<String> miniPlans = convertMiniPlansJsonToList(feedback.getMiniPlansJson());
            return JournalResponseDto.fromEntities(journalLog, feedback, miniPlans);
        }
        // 피드백 누락 시: AI 피드백 생성 로직 수행
        System.out.println(" Warning: AIFeedback missing for Log ID " + journalLog.getId() + ". Regenerating feedback...");

        String personaId = String.valueOf(user.getAiPersonaId());
        String userName = (user.getName() != null && !user.getName().trim().isEmpty()) ? user.getName() : "사용자";
        // 단기 기억 조회 (피드백을 생성할 저널 날짜 기준 이전 3일)
        LocalDate targetDate = journalLog.getJournalDate();
        List<JournalLog> recentLogs = journalLogRepository.findTop3ByUserAndJournalDateBeforeOrderByJournalDateDesc(user, targetDate);
        // 장기 기억 읽기
        String habitSummary = user.getHabitHistorySummary();

        String prompt = createGeminiPrompt(personaId, userName, journalLog.getContent(), habitSummary, recentLogs);
        // Gemini API 동기 호출 및 결과 획득
        GeminiResponse geminiResponse = geminiClientService.generateContent(prompt).block();

        if (geminiResponse == null) {
            throw new RuntimeException("AI 피드백 재생성에 실패했습니다. Gemini 응답 없음.");
        }

        // 응답 파싱 및 DB 저장
        String rawText = geminiResponse.getGeneratedText();
        JournalResponse parsedResponse = aiPipelineService.parseGeminiResponse(rawText);
        try {
            AIFeedback newFeedback = new AIFeedback();
            newFeedback.setJournal(journalLog);
            newFeedback.setMentText(parsedResponse.getMentText());
            newFeedback.setMiniPlansJson(objectMapper.writeValueAsString(parsedResponse.getMiniPlans()));
            aiFeedbackRepository.save(newFeedback);

            return JournalResponseDto.fromEntities(journalLog, newFeedback, parsedResponse.getMiniPlans());

        } catch (JsonProcessingException e) {
            throw new RuntimeException("AI 응답 JSON 처리 중 오류 발생.", e);
        }
    }


}