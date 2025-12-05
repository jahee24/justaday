package io.github.jahee24.justaday.service;

import io.github.jahee24.justaday.dto.JournalRequest;
import io.github.jahee24.justaday.dto.JournalResponse;
import io.github.jahee24.justaday.dto.JournalResponseDto;

import java.util.List;
import java.util.Optional;

public interface AILogService {
    JournalResponse submitJournalAndGetFeedback(String userId, JournalRequest request);

    Optional<JournalResponseDto> findLatestJournalLog(String userId);

    List<JournalResponseDto> findAllJournalLogs(String userId);
}
