// src/main/java/io/github/jahee24/justaday/repository/JournalLogRepository.java
package io.github.jahee24.justaday.repository;

import io.github.jahee24.justaday.entity.JournalLog;
import io.github.jahee24.justaday.entity.User;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
public interface JournalLogRepository extends JpaRepository<JournalLog, Long> {
    // 특정 사용자가 오늘 작성한 저널을 찾는 쿼리 (하루 한 번 저널 제한 로직을 위한 DB 측 검증)
    Optional<JournalLog> findByUserIdAndJournalDate(Long userId, LocalDate journalDate);

    // 전체 로그 목록 조회 (Lazy 로딩 상태 유지)
    List<JournalLog> findByUser(User user, Sort sort);

    // 1. 단기 기억용: 오늘을 제외한 최근 3개 로그 조회 (JournalDate 기준 내림차순)
    @Query(value = "SELECT jl FROM JournalLog jl WHERE jl.user = :user AND jl.journalDate < :date ORDER BY jl.journalDate DESC LIMIT 3")
    List<JournalLog> findTop3ByUserAndJournalDateBeforeOrderByJournalDateDesc(@Param("user") User user, @Param("date") LocalDate date);
    // 2. 장기 기억 업데이트용: 업데이트 시점 (7일 전) 이후의 모든 로그 조회
    @Query(value = "SELECT jl FROM JournalLog jl WHERE jl.user = :user AND jl.journalDate >= :date ORDER BY jl.journalDate ASC")
    List<JournalLog> findByUserAndJournalDateAfter(@Param("user") User user, @Param("date") LocalDate date);}