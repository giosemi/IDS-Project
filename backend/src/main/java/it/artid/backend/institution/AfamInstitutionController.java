package it.artid.backend.institution;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/institutions")
@RequiredArgsConstructor
public class AfamInstitutionController {

    private final AfamInstitutionService service;

    @GetMapping("/afam")
    public ResponseEntity<List<AfamInstitutionDto>> listAfamInstitutions() {
        return ResponseEntity.ok(service.listAll());
    }
}
