package it.artid.backend.portfolio;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/portfolio/sections")
@RequiredArgsConstructor
public class PortfolioSectionsController {

    private final PortfolioService portfolioService;

    @GetMapping
    public List<PortfolioSectionEntity> getSections(@AuthenticationPrincipal String userId) {
        return portfolioService.getSections(userId);
    }

    @PostMapping
    public ResponseEntity<PortfolioSectionEntity> addSection(
            @AuthenticationPrincipal String userId,
            @Valid @RequestBody SectionTitleRequest req) {
        return ResponseEntity.status(HttpStatus.CREATED).body(portfolioService.addSection(userId, req.getTitle()));
    }

    @PutMapping("/reorder")
    public ResponseEntity<Void> reorder(
            @AuthenticationPrincipal String userId,
            @RequestBody ReorderRequest req) {
        portfolioService.reorder(userId, req.ids());
        return ResponseEntity.ok().build();
    }

    @PutMapping("/{id}")
    public ResponseEntity<PortfolioSectionEntity> rename(
            @AuthenticationPrincipal String userId,
            @PathVariable String id,
            @Valid @RequestBody SectionTitleRequest req) {
        return ResponseEntity.ok(portfolioService.renameSection(userId, id, req.getTitle()));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(
            @AuthenticationPrincipal String userId,
            @PathVariable String id) {
        portfolioService.deleteSection(userId, id);
        return ResponseEntity.noContent().build();
    }

    @PutMapping("/{id}/assign")
    public ResponseEntity<Void> assign(
            @AuthenticationPrincipal String userId,
            @PathVariable String id,
            @RequestBody AssignRequest req) {
        portfolioService.assignContent(userId, id, req.contentId());
        return ResponseEntity.ok().build();
    }
}
