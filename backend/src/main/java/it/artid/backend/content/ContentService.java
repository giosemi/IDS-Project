package it.artid.backend.content;

import it.artid.backend.portfolio.PortfolioSectionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class ContentService {

    private final ContentRepository contentRepository;
    private final PortfolioSectionRepository sectionRepository;

    public List<ContentItemEntity> getByOwner(String ownerId) {
        return contentRepository.findByOwnerId(ownerId);
    }

    public ContentItemEntity create(String ownerId, ContentRequest req) {
        var item = ContentItemEntity.builder()
                .id(UUID.randomUUID().toString())
                .title(req.getTitle())
                .description(req.getDescription())
                .year(req.getYear())
                .ownerId(ownerId)
                .type(req.getType())
                .technique(req.getTechnique())
                .dimensions(req.getDimensions())
                .duration(req.getDuration())
                .subtitle(req.getSubtitle())
                .fileName(req.getFileName())
                .build();
        return contentRepository.save(item);
    }

    @Transactional
    public ContentItemEntity update(String id, String ownerId, ContentRequest req) {
        var item = findOwned(id, ownerId);
        if (req.getTitle()       != null) item.setTitle(req.getTitle());
        if (req.getDescription() != null) item.setDescription(req.getDescription());
        if (req.getYear()        != null) item.setYear(req.getYear());
        if (req.getType()        != null) item.setType(req.getType());
        if (req.getTechnique()   != null) item.setTechnique(req.getTechnique());
        if (req.getDimensions()  != null) item.setDimensions(req.getDimensions());
        if (req.getDuration()    != null) item.setDuration(req.getDuration());
        if (req.getSubtitle()    != null) item.setSubtitle(req.getSubtitle());
        if (req.getFileName()    != null) item.setFileName(req.getFileName());
        return contentRepository.save(item);
    }

    @Transactional
    public void delete(String id, String ownerId) {
        findOwned(id, ownerId);
        contentRepository.deleteById(id);
        sectionRepository.findAll().forEach(section -> {
            section.getContentIds().remove(id);
            sectionRepository.save(section);
        });
    }

    public List<ContentItemEntity> findByIds(List<String> ids) {
        return contentRepository.findByIdIn(ids);
    }

    public List<ContentItemEntity> search(String q) {
        if (q == null || q.isBlank()) return List.of();
        return contentRepository.search(q.trim());
    }

    private ContentItemEntity findOwned(String id, String ownerId) {
        var item = contentRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Contenuto non trovato"));
        if (!item.getOwnerId().equals(ownerId)) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Non autorizzato");
        }
        return item;
    }
}
