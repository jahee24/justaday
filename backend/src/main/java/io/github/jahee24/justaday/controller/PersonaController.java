package io.github.jahee24.justaday.controller;

import io.github.jahee24.justaday.constant.AIPersona;
import io.github.jahee24.justaday.dto.PersonaDto;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/v1/personas")
public class PersonaController {

    @GetMapping
    public ResponseEntity<List<PersonaDto>> getPersonas() {
        List<PersonaDto> personaList = Arrays.stream(AIPersona.values())
                .map(PersonaDto::from)
                .collect(Collectors.toList());
        return ResponseEntity.ok(personaList);
    }
}
