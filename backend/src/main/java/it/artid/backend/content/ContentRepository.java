package it.artid.backend.content;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import java.util.Collection;
import java.util.List;

public interface ContentRepository extends JpaRepository<ContentItemEntity, String> {
    List<ContentItemEntity> findByOwnerId(String ownerId);
    List<ContentItemEntity> findByIdIn(Collection<String> ids);

    @Query("SELECT c FROM ContentItemEntity c WHERE " +
           "LOWER(c.title) LIKE LOWER(CONCAT('%', :q, '%')) OR " +
           "LOWER(c.description) LIKE LOWER(CONCAT('%', :q, '%'))")
    List<ContentItemEntity> search(String q);
}
