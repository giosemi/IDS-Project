package it.artid.backend.institution;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class AfamInstitutionService {

    private final AfamInstitutionRepository repository;

    public List<AfamInstitutionDto> listAll() {
        return repository.findAllByOrderByNameAsc().stream()
                .map(AfamInstitutionDto::from)
                .toList();
    }

    @Transactional
    public void seedIfEmpty() {
        if (repository.count() > 0) return;

        var institutions = List.of(
                institution("Accademia di Belle Arti di Bologna", "Bologna"),
                institution("Accademia di Belle Arti di Brera", "Milano"),
                institution("Accademia di Belle Arti di Firenze", "Firenze"),
                institution("Accademia di Belle Arti di Napoli", "Napoli"),
                institution("Accademia di Belle Arti di Palermo", "Palermo"),
                institution("Accademia di Belle Arti di Roma", "Roma"),
                institution("Accademia di Belle Arti di Venezia", "Venezia"),
                institution("Conservatorio di Musica Giuseppe Verdi", "Torino"),
                institution("Conservatorio di Musica Santa Cecilia", "Roma"),
                institution("ISIA Istituto Superiore per le Industrie Artistiche", "Faenza")
        );
        repository.saveAll(institutions);
    }

    private AfamInstitutionEntity institution(String name, String city) {
        return AfamInstitutionEntity.builder()
                .id(UUID.randomUUID().toString())
                .name(name)
                .city(city)
                .build();
    }
}
