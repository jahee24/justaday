package io.github.jahee24.justaday.service;

import io.github.jahee24.justaday.dto.JournalResponse;
import io.github.jahee24.justaday.entity.JournalLog;

public interface AIPipelineService {
    void generateAndSaveFeedback(String prompt, JournalLog savedLog);
    JournalResponse parseGeminiResponse(String rawText);
}
