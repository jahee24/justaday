// src/main/java/io/github/jahee24/justaday/scheduler/SummaryScheduler.java (수정)

package io.github.jahee24.justaday.scheduler;

import io.github.jahee24.justaday.service.AISummaryService;
import io.github.jahee24.justaday.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import net.javacrumbs.shedlock.spring.annotation.SchedulerLock;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.util.List;

@Component
@RequiredArgsConstructor
public class SummaryScheduler {

    private final UserRepository userRepository;
    private final AISummaryService aiSummaryService;
    @Scheduled(cron = "0 0 3 * * *")
    @SchedulerLock(
            name = "SummaryUpdateTask", // 락 이름 (shedlock 테이블의 name 컬럼에 저장됨)
            lockAtLeastFor = "PT1M",    // 최소 1분 동안은 락을 유지 (잦은 실행 방지)
            lockAtMostFor = "PT10M"     // 최대 10분 동안 락 유지 (작업 실패 시 데드락 방지)
    )
    public void runDailySummaryUpdate() {
        System.out.println("[ShedLock] 락 획득 성공. 장기 기억 업데이트 시작.");
        try {

            // 2. 모든 사용자 ID 조회
            List<Long> userIds = userRepository.findAllUserIds();

            // 3. 각 사용자별로 업데이트 로직 실행
            for (Long userId : userIds) {
                aiSummaryService.updateHabitHistorySummary(userId);
            }

            System.out.println("장기 기억 업데이트 완료.");

        } catch (Exception e) {
            System.err.println("스케줄러 실행 중 예상치 못한 오류 발생: " + e.getMessage());
        }
    }
}