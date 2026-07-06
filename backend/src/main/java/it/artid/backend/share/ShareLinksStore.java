package it.artid.backend.share;



import java.time.Instant;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;


public class ShareLinksStore {

    public record ShareLink(
            String id,
            String token,
            String ownerId,
            String label,
            Instant createdAt,
            List<String> contentIds,
            boolean includeProfile,
            Instant expiresAt,
            int viewCount,
            Instant lastViewedAt
    ) {
        public boolean isExpired() {
            return expiresAt != null && Instant.now().isAfter(expiresAt);
        }

        public String shareUrl() {
            return "https://artid.afam.it/s/" + token;
        }
    }

    private final Map<String, ShareLink> links = new ConcurrentHashMap<>();

    public ShareLink create(String ownerId, CreateShareLinkRequest req) {
        var link = new ShareLink(
                UUID.randomUUID().toString(),
                "afam-" + Long.toString(System.currentTimeMillis(), 36),
                ownerId, req.getLabel(), Instant.now(),
                List.copyOf(req.getContentIds()),
                req.isIncludeProfile(), req.getExpiresAt(), 0, null
        );
        links.put(link.id(), link);
        return link;
    }

    public boolean delete(String id) {
        return links.remove(id) != null;
    }

    public List<ShareLink> findByOwner(String ownerId) {
        return links.values().stream().filter(l -> l.ownerId().equals(ownerId)).toList();
    }

    public ShareLink findByToken(String token) {
        return links.values().stream().filter(l -> l.token().equals(token)).findFirst().orElse(null);
    }

    public ShareLink recordView(String token) {
        var link = findByToken(token);
        if (link == null || link.isExpired()) return null;
        var updated = new ShareLink(link.id(), link.token(), link.ownerId(), link.label(),
                link.createdAt(), link.contentIds(), link.includeProfile(), link.expiresAt(),
                link.viewCount() + 1, Instant.now());
        links.put(updated.id(), updated);
        return updated;
    }
}
