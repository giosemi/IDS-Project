package it.artid.backend.content;

import it.artid.backend.portfolio.PortfolioSectionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.core.io.Resource;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.MediaTypeFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class ContentService {

    private final ContentRepository contentRepository;
    private final PortfolioSectionRepository sectionRepository;
    private final ContentStorageService storageService;

    public List<ContentItemEntity> getByOwner(String ownerId) {
        return contentRepository.findByOwnerId(ownerId).stream()
                .peek(this::enrichHasMedia)
                .toList();
    }

    public ContentItemEntity findById(String id) {
        return contentRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Contenuto non trovato"));
    }

    @Transactional
    public ContentItemEntity create(String ownerId, ContentRequest req, MultipartFile file) {
        var item = ContentItemEntity.builder()
                .id(UUID.randomUUID().toString())
                .title(req.getTitle())
                .description(req.getDescription())
                .year(req.getYear())
                .ownerId(ownerId)
                .type(req.getType())
                .duration(req.getDuration())
                .fileName(req.getFileName())
                .build();
        var saved = contentRepository.save(item);
        if (file != null && !file.isEmpty()) {
            storageService.store(saved.getId(), file);
        }
        enrichHasMedia(saved);
        return saved;
    }

    @Transactional
    public ContentItemEntity update(String id, String ownerId, ContentRequest req, MultipartFile file) {
        var item = findOwned(id, ownerId);
        if (req.getTitle()       != null) item.setTitle(req.getTitle());
        if (req.getDescription() != null) item.setDescription(req.getDescription());
        if (req.getYear()        != null) item.setYear(req.getYear());
        if (req.getType()        != null) item.setType(req.getType());
        if (req.getDuration()    != null) item.setDuration(req.getDuration());
        if (req.getFileName()    != null) item.setFileName(req.getFileName());
        var saved = contentRepository.save(item);
        if (file != null && !file.isEmpty()) {
            storageService.store(saved.getId(), file);
        }
        enrichHasMedia(saved);
        return saved;
    }

    @Transactional
    public void delete(String id, String ownerId) {
        findOwned(id, ownerId);
        storageService.delete(id);
        contentRepository.deleteById(id);
        sectionRepository.findAll().forEach(section -> {
            section.getContentIds().remove(id);
            sectionRepository.save(section);
        });
    }

    public ResponseEntity<Resource> loadMedia(String id, String ownerId) {
        findOwned(id, ownerId);
        return buildMediaResponse(id, findById(id).getFileName());
    }

    public ResponseEntity<Resource> loadMedia(String id) {
        if (!storageService.exists(id)) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "File non trovato");
        }
        var item = findById(id);
        return buildMediaResponse(id, item.getFileName());
    }

    public List<ContentItemEntity> findByIds(List<String> ids) {
        return contentRepository.findByIdIn(ids).stream()
                .peek(this::enrichHasMedia)
                .toList();
    }

    public List<ContentItemEntity> search(String q) {
        if (q == null || q.isBlank()) return List.of();
        return contentRepository.search(q.trim());
    }

    private ResponseEntity<Resource> buildMediaResponse(String contentId, String fileName) {
        var resource = storageService.load(contentId);
        var mediaType = MediaTypeFactory.getMediaType(fileName != null ? fileName : contentId)
                .orElse(MediaType.APPLICATION_OCTET_STREAM);
        var responseHeaders = new org.springframework.http.HttpHeaders();
        if (fileName != null && !fileName.isBlank()) {
            responseHeaders.set(org.springframework.http.HttpHeaders.CONTENT_DISPOSITION, "inline; filename=\"" + fileName + "\"");
        }
        responseHeaders.setContentType(mediaType);
        return ResponseEntity.ok().headers(responseHeaders).body(resource);
    }

    private void enrichHasMedia(ContentItemEntity item) {
        item.setHasMedia(storageService.exists(item.getId()));
    }

    private ContentItemEntity findOwned(String id, String ownerId) {
        var item = findById(id);
        if (!item.getOwnerId().equals(ownerId)) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Non autorizzato");
        }
        return item;
    }
}
