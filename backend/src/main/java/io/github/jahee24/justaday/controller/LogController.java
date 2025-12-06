// src/main/java/io/github/jahee24/justaday/controller/LogController.java
package io.github.jahee24.justaday.controller;

import com.fasterxml.jackson.core.JsonProcessingException;
import io.github.jahee24.justaday.dto.JournalRequest;
import io.github.jahee24.justaday.dto.JournalResponse;
import io.github.jahee24.justaday.dto.JournalWithFeedbackResponseDTO;
import io.github.jahee24.justaday.service.AILogService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.web.ErrorResponseException;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.reactive.function.client.WebClientResponseException;
import reactor.core.publisher.Mono;

import java.util.List;
import java.util.concurrent.ExecutionException;

@RestController
@RequestMapping("/api/v1/log")
@RequiredArgsConstructor
@Slf4j
public class LogController {

    private final AILogService aiLogService;

    // Helper: Security Context에서 userId 추출
    private String getCurrentUserId() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        return authentication.getName();
    }

    // POST /api/v1/log: 저널 입력 및 AI 피드백 요청 (Core API)
    @PostMapping
    public ResponseEntity<JournalResponse> submitJournal(@Valid @RequestBody JournalRequest request) {
        String userId = getCurrentUserId();
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        log.debug("📝 [JOURNAL SUBMIT] User: {}, Thread: {}", userId, Thread.currentThread().getName());

        try {
            JournalResponse response = aiLogService.submitJournalAndGetFeedback(userId, request);
            log.debug("✅ [JOURNAL SAVED] User: {}, Async AI processing started", userId);
            return ResponseEntity.status(HttpStatus.CREATED).body(response);
        } catch (IllegalStateException e) {
            log.warn("⚠️ [JOURNAL CONFLICT] User: {}, Message: {}", userId, e.getMessage());
            return ResponseEntity.status(HttpStatus.CONFLICT).body(createErrorResponse(HttpStatus.CONFLICT.value(), e.getMessage()));
        } catch (UsernameNotFoundException e) {
            log.warn("User not found: {}", userId);
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(createErrorResponse(HttpStatus.NOT_FOUND.value(), "제출 사용자를 찾을 수 없습니다."));
        } catch (Exception e) {
            log.error("❌ [JOURNAL ERROR] User: {}, Error: {}", userId, e.getMessage(), e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(createErrorResponse(HttpStatus.INTERNAL_SERVER_ERROR.value(), "저널 제출 중 시스템 오류가 발생했습니다."));
        }
    }

    @GetMapping("/latest")
    public ResponseEntity<JournalWithFeedbackResponseDTO> getLatestJournalLog() {
        String userId = getCurrentUserId();

        try {
            JournalWithFeedbackResponseDTO response = aiLogService.findLatestJournalLog(userId);

            if (response == null) {
                // 오늘 작성한 저널이 없음
                log.debug("📭 [NO JOURNAL] User: {} has no journal today", userId);
                return ResponseEntity.notFound().build();
            }

            if (response.getResponseCode() == 102) {
                // 저널은 있지만 AI 피드백이 아직 준비 중
                log.debug("⏳ [FEEDBACK PENDING] User: {}, Journal ID: {}, getResponseCode() == 102(Processing-pending)", userId, response.getId());
                return ResponseEntity.status(HttpStatus.ACCEPTED) // 202 Accepted
                        .body(response);
            }

            // 저널과 피드백 모두 준비됨
            log.debug("✅ [FEEDBACK READY] User: {}, Journal ID: {}, Feedbacks Content: {}",
                    userId, response.getId(), response.getContent());
            return ResponseEntity.ok(response);

        } catch (UsernameNotFoundException e) {
            log.error("❌ [USER NOT FOUND] User: {}", userId);
            return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
        } catch (Exception e) {
            log.error("❌ [GET LATEST ERROR] User: {}, Error: {}", userId, e.getMessage(), e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    @GetMapping("/getall")
    public ResponseEntity<List<JournalWithFeedbackResponseDTO>> getAllJournalLogs() {
        String userId = getCurrentUserId();

        List<JournalWithFeedbackResponseDTO> logs = aiLogService.findAllJournalLogs(userId);
        return ResponseEntity.ok(logs);
    }

    private JournalResponse createErrorResponse(int code, String message) {
        return JournalResponse.builder()
                .mentText(message)
                .responseCode(code)
                .miniPlans(List.of())
                .build();
    }

}