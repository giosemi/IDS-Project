package it.artid.backend.portfolio;



import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;


public class SectionsStore {

    public record PortfolioSection(String id, String title, List<String> contentIds) {}

    private final Map<String, List<PortfolioSection>> store = new ConcurrentHashMap<>();

    private List<PortfolioSection> listFor(String userId) {
        return store.computeIfAbsent(userId, k -> new ArrayList<>());
    }

    public List<PortfolioSection> getAll(String userId) {
        return List.copyOf(listFor(userId));
    }

    public PortfolioSection add(String userId, String title) {
        var section = new PortfolioSection(UUID.randomUUID().toString(), title, new ArrayList<>());
        listFor(userId).add(section);
        return section;
    }

    public PortfolioSection rename(String userId, String sectionId, String title) {
        var sections = listFor(userId);
        for (int i = 0; i < sections.size(); i++) {
            if (sections.get(i).id().equals(sectionId)) {
                var updated = new PortfolioSection(sectionId, title, sections.get(i).contentIds());
                sections.set(i, updated);
                return updated;
            }
        }
        return null;
    }

    public boolean remove(String userId, String sectionId) {
        return listFor(userId).removeIf(s -> s.id().equals(sectionId));
    }

    public void reorder(String userId, List<String> orderedIds) {
        var sections = listFor(userId);
        var map = new java.util.LinkedHashMap<String, PortfolioSection>();
        sections.forEach(s -> map.put(s.id(), s));
        sections.clear();
        orderedIds.stream().map(map::get).filter(s -> s != null).forEach(sections::add);
    }

    public void assign(String userId, String sectionId, String contentId) {
        listFor(userId).forEach(s -> s.contentIds().remove(contentId));
        listFor(userId).stream()
                .filter(s -> s.id().equals(sectionId))
                .findFirst()
                .ifPresent(s -> s.contentIds().add(contentId));
    }

    public void removeContentFromSections(String userId, String contentId) {
        listFor(userId).forEach(s -> s.contentIds().remove(contentId));
    }
}
