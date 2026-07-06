package it.artid.backend.share;

import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;

public interface ShareLinkRepository extends JpaRepository<ShareLinkEntity, String> {
    List<ShareLinkEntity> findByOwnerId(String ownerId);
    Optional<ShareLinkEntity> findByToken(String token);
}
