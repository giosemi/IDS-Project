package it.artid.backend.content;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/content")
@RequiredArgsConstructor
public class ContentController {

    private final ContentService contentService;

    @GetMapping
    public List<ContentItemEntity> getMyContent(@AuthenticationPrincipal String userId) {
        return contentService.getByOwner(userId);
    }

    @PostMapping
    public ResponseEntity<ContentItemEntity> create(
            @AuthenticationPrincipal String userId,
            @Valid @RequestBody ContentRequest req) {
        return ResponseEntity.status(HttpStatus.CREATED).body(contentService.create(userId, req));
    }

    @PutMapping("/{id}")
    public ResponseEntity<ContentItemEntity> update(
            @AuthenticationPrincipal String userId,
            @PathVariable String id,
            @RequestBody ContentRequest req) {
        return ResponseEntity.ok(contentService.update(id, userId, req));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(
            @AuthenticationPrincipal String userId,
            @PathVariable String id) {
        contentService.delete(id, userId);
        return ResponseEntity.noContent().build();
    }
}
