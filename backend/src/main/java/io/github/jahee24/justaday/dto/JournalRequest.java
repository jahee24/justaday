// src/main/java/io/github/jahee24/justaday/dto/JournalRequest.java
package io.github.jahee24.justaday.dto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class JournalRequest {
    @Min(value = 1, message = "상태 레벨은 1 이상이어야 합니다.")
    @Max(value = 3, message = "상태 레벨은 3 이하이어야 합니다.")
    private int status;

    @NotBlank(message = "저널 행동은 비워둘 수 없습니다.")
    private String journalAction;

    @NotBlank(message = "저널 감정은 비워둘 수 없습니다.")
    private String journalEmotion;

    // 저널의 핵심 내용이므로 필수 항목으로 유지
    @NotBlank(message = "저널 내용은 비워둘 수 없습니다.")
    private String journalContext;

    // AI 서비스에서 사용할 통합 content 필드는 Service 계층에서 생성합니다.
}