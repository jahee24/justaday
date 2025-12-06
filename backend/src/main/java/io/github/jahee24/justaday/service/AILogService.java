package io.github.jahee24.justaday.service;

import io.github.jahee24.justaday.dto.JournalRequest;
import io.github.jahee24.justaday.dto.JournalResponse;
import io.github.jahee24.justaday.dto.JournalWithFeedbackResponseDTO;

import java.util.List;

public interface AILogService {
    JournalResponse submitJournalAndGetFeedback(String userId, JournalRequest request);

    JournalWithFeedbackResponseDTO findLatestJournalLog(String userId);

    List<JournalWithFeedbackResponseDTO> findAllJournalLogs(String userId);
}
