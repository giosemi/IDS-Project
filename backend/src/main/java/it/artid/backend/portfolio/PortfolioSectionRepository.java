package it.artid.backend.portfolio;

import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface PortfolioSectionRepository extends JpaRepository<PortfolioSectionEntity, String> {
    List<PortfolioSectionEntity> findByUserIdOrderByDisplayOrder(String userId);
}
