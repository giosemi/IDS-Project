package it.artid.backend.share;

import it.artid.backend.content.ContentItemEntity;
import it.artid.backend.content.ContentService;
import it.artid.backend.profile.ProfileService;
import it.artid.backend.profile.StudentProfileEntity;
import lombok.RequiredArgsConstructor;
import org.springframework.core.io.Resource;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class ShareLinksService {

    private final ShareLinkRepository shareLinkRepository;
    private final ContentService contentService;
    private final ProfileService profileService;

    public List<ShareLinkEntity> getByOwner(String ownerId) {
        return shareLinkRepository.findByOwnerId(ownerId);
    }

    public ShareLinkEntity create(String ownerId, CreateShareLinkRequest req) {
        var link = ShareLinkEntity.builder()
                .id(UUID.randomUUID().toString())
                .token("afam-" + Long.toString(System.currentTimeMillis(), 36))
                .ownerId(ownerId).label(req.getLabel())
                .createdAt(Instant.now())
                .contentIds(req.getContentIds())
                .includeProfile(req.isIncludeProfile())
                .expiresAt(req.getExpiresAt())
                .viewCount(0)
                .build();
        return shareLinkRepository.save(link);
    }

    @Transactional
    public void delete(String id, String ownerId) {
        var link = shareLinkRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Link non trovato"));
        if (!link.getOwnerId().equals(ownerId)) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Non autorizzato");
        }
        shareLinkRepository.delete(link);
    }

    @Transactional
    public SharedView viewByToken(String token) {
        var link = shareLinkRepository.findByToken(token)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Link non trovato"));
        if (link.isExpired()) {
            throw new ResponseStatusException(HttpStatus.GONE, "Link scaduto");
        }
        link.setViewCount(link.getViewCount() + 1);
        link.setLastViewedAt(Instant.now());
        shareLinkRepository.save(link);

        List<ContentItemEntity> items = contentService.findByIds(link.getContentIds());
        StudentProfileEntity profile = link.isIncludeProfile() ? profileService.get(link.getOwnerId()) : null;
        return new SharedView(link.getLabel(), link.getToken(), profile, items);
    }

    public record SharedView(String label, String token, StudentProfileEntity profile, List<ContentItemEntity> items) {}

    public ResponseEntity<Resource> loadSharedMedia(String token, String contentId) {
        var link = shareLinkRepository.findByToken(token)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Link non trovato"));
        if (link.isExpired()) {
            throw new ResponseStatusException(HttpStatus.GONE, "Link scaduto");
        }
        if (!link.getContentIds().contains(contentId)) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Contenuto non condiviso");
        }
        return contentService.loadMedia(contentId);
    }
}
