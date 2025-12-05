//src/main/java/io/github/jahee24/justaday/dto/SignupRequest.java
package io.github.jahee24.justaday.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@NoArgsConstructor
@AllArgsConstructor
@Data
public class SignupRequest {
    @NotBlank(message = "사용자 ID는 필수입니다.")
    @Size(min = 4, max = 20, message = "ID는 4자 이상 20자 이하이어야 합니다.")
    private String userId;

    @NotBlank(message = "비밀번호는 필수입니다.")
    @Size(min = 6, message = "비밀번호는 6자 이상이어야 합니다.")
    private String password;

    // AI 페르소나 초기 설정 (UX 개선: 클라이언트에서 선택하도록 유도)
    @NotNull(message = "AI 페르소나 ID는 필수입니다.")
    private Integer aiPersonaId; // 1:미르, 2:알파, 3:오든

}
