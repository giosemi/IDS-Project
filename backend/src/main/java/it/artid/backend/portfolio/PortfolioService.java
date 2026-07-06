package it.artid.backend.portfolio;

import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.util.HashMap;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class PortfolioService {

    private final PortfolioSectionRepository sectionRepository;

    public List<PortfolioSectionEntity> getSections(String userId) {
        return sectionRepository.findByUserIdOrderByDisplayOrder(userId);
    }

    @Transactional
    public PortfolioSectionEntity addSection(String userId, String title) {
        int maxOrder = sectionRepository.findByUserIdOrderByDisplayOrder(userId).stream()
                .mapToInt(PortfolioSectionEntity::getDisplayOrder).max().orElse(-1);
        var section = PortfolioSectionEntity.builder()
                .id(UUID.randomUUID().toString())
                .userId(userId).title(title.trim())
                .displayOrder(maxOrder + 1)
                .build();
        return sectionRepository.save(section);
    }

    @Transactional
    public PortfolioSectionEntity renameSection(String userId, String sectionId, String title) {
        var section = findOwned(sectionId, userId);
        section.setTitle(title.trim());
        return sectionRepository.save(section);
    }

    @Transactional
    public void deleteSection(String userId, String sectionId) {
        sectionRepository.delete(findOwned(sectionId, userId));
    }

    @Transactional
    public void reorder(String userId, List<String> orderedIds) {
        var sections = sectionRepository.findByUserIdOrderByDisplayOrder(userId);
        var map = new HashMap<String, PortfolioSectionEntity>();
        sections.forEach(s -> map.put(s.getId(), s));
        for (int i = 0; i < orderedIds.size(); i++) {
            var s = map.get(orderedIds.get(i));
            if (s != null) {
                s.setDisplayOrder(i);
                sectionRepository.save(s);
            }
        }
    }

    @Transactional
    public void assignContent(String userId, String sectionId, String contentId) {
        sectionRepository.findByUserIdOrderByDisplayOrder(userId).forEach(s -> {
            s.getContentIds().remove(contentId);
            sectionRepository.save(s);
        });
        var target = findOwned(sectionId, userId);
        target.getContentIds().add(contentId);
        sectionRepository.save(target);
    }

    private PortfolioSectionEntity findOwned(String sectionId, String userId) {
        var section = sectionRepository.findById(sectionId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Sezione non trovata"));
        if (!section.getUserId().equals(userId)) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Non autorizzato");
        }
        return section;
    }
}
