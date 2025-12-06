package io.github.jahee24.justaday.dto;

import io.github.jahee24.justaday.constant.AIPersona;
import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class PersonaDto {
    private int id;
    private String code;
    private String name;
    private String role;
    private String tagline;
    private String description;
    private String[] keywords;
    private String mentGuide;
    private String themeColor;

    public static PersonaDto from(AIPersona persona) {
        return new PersonaDto(
                persona.getId(),
                persona.getCode(),
                persona.getName(),
                persona.getRole(),
                persona.getTagline(),
                persona.getDescription(),
                persona.getKeywords(),
                persona.getMentGuide(),
                persona.getThemeColor()
        );
    }
}
