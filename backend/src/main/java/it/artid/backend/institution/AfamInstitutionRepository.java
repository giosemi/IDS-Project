package it.artid.backend.institution;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface AfamInstitutionRepository extends JpaRepository<AfamInstitutionEntity, String> {
    List<AfamInstitutionEntity> findAllByOrderByNameAsc();
}
