package it.artid.backend.content;



import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;


public class ContentStore {

    public record ContentItem(
            String id,
            String title,
            String description,
            int year,
            String ownerId,
            ContentType type,
            String technique,
            String dimensions,
            String duration,
            String subtitle,
            String fileName
    ) {}

    private final Map<String, ContentItem> items = new ConcurrentHashMap<>();

    public ContentItem create(String ownerId, ContentRequest req) {
        var item = new ContentItem(
                UUID.randomUUID().toString(),
                req.getTitle(), req.getDescription(), req.getYear(), ownerId,
                req.getType(), req.getTechnique(), req.getDimensions(),
                req.getDuration(), req.getSubtitle(), req.getFileName()
        );
        items.put(item.id(), item);
        return item;
    }

    public ContentItem update(String id, ContentRequest req) {
        var existing = items.get(id);
        if (existing == null) return null;
        var updated = new ContentItem(
                id,
                req.getTitle()       != null ? req.getTitle()       : existing.title(),
                req.getDescription() != null ? req.getDescription() : existing.description(),
                req.getYear()        != null ? req.getYear()        : existing.year(),
                existing.ownerId(),
                req.getType()        != null ? req.getType()        : existing.type(),
                req.getTechnique()   != null ? req.getTechnique()   : existing.technique(),
                req.getDimensions()  != null ? req.getDimensions()  : existing.dimensions(),
                req.getDuration()    != null ? req.getDuration()    : existing.duration(),
                req.getSubtitle()    != null ? req.getSubtitle()    : existing.subtitle(),
                req.getFileName()    != null ? req.getFileName()    : existing.fileName()
        );
        items.put(id, updated);
        return updated;
    }

    public boolean delete(String id) {
        return items.remove(id) != null;
    }

    public ContentItem findById(String id) {
        return items.get(id);
    }

    public List<ContentItem> findByOwner(String ownerId) {
        return items.values().stream().filter(i -> i.ownerId().equals(ownerId)).toList();
    }

    public List<ContentItem> findByIds(List<String> ids) {
        var idSet = Set.copyOf(ids);
        return items.values().stream().filter(i -> idSet.contains(i.id())).toList();
    }

    public List<ContentItem> search(String query) {
        String q = query.toLowerCase();
        return items.values().stream()
                .filter(i -> i.title().toLowerCase().contains(q)
                        || i.description().toLowerCase().contains(q)
                        || (i.subtitle() != null && i.subtitle().toLowerCase().contains(q)))
                .toList();
    }
}
