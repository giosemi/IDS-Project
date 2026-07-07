package it.artid.backend.institution;

import lombok.RequiredArgsConstructor;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class AfamInstitutionSeeder implements ApplicationRunner {

    private final AfamInstitutionService service;

    @Override
    public void run(ApplicationArguments args) {
        service.seedIfEmpty();
    }
}
