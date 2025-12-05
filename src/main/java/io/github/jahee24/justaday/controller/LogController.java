// src/main/java/io/github/jahee24/justaday/controller/LogController.java
package io.github.jahee24.justaday.controller;

import com.fasterxml.jackson.core.JsonProcessingException;
import io.github.jahee24.justaday.dto.JournalRequest;
import io.github.jahee24.justaday.dto.JournalResponse;
import io.github.jahee24.justaday.dto.JournalResponseDto;
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

        try{
            JournalResponse response = aiLogService.submitJournalAndGetFeedback(userId, request);
            log.debug("✅ [JOURNAL SAVED] User: {}, Async AI processing started", userId);
            return ResponseEntity.status(HttpStatus.CREATED).body(response);
        }catch (IllegalStateException e){
            log.warn("⚠️ [JOURNAL CONFLICT] User: {}, Message: {}", userId, e.getMessage());
            return ResponseEntity.status(HttpStatus.CONFLICT).body(createErrorResponse(HttpStatus.CONFLICT.value(),e.getMessage()));
        }
        catch (UsernameNotFoundException e){
            log.warn("User not found: {}", userId);
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(createErrorResponse(HttpStatus.NOT_FOUND.value(),"제출 사용자를 찾을 수 없습니다."));
        }catch(Exception e){
            log.error("❌ [JOURNAL ERROR] User: {}, Error: {}", userId, e.getMessage(), e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(createErrorResponse(HttpStatus.INTERNAL_SERVER_ERROR.value(), "저널 제출 중 시스템 오류가 발생했습니다."));
        }
    }

    @GetMapping("/latest")
    public ResponseEntity<JournalResponseDto> getLatestJournalLog() {
        String userId = getCurrentUserId();

        return aiLogService.findLatestJournalLog(userId)
                .map(ResponseEntity::ok)
                //오늘 작성된 로그가 없으면 204 No Content 반환
                .orElseGet(() -> ResponseEntity.status(HttpStatus.NO_CONTENT).build());
    }

    @GetMapping("/getall")
    public ResponseEntity<List<JournalResponseDto>> getAllJournalLogs() {
        String userId = getCurrentUserId();

        List<JournalResponseDto> logs = aiLogService.findAllJournalLogs(userId);
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