package it.artid.backend.share;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.core.io.Resource;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequiredArgsConstructor
public class ShareLinksController {

    private final ShareLinksService shareLinksService;

    @GetMapping("/api/share-links")
    public List<ShareLinkEntity> getMyLinks(@AuthenticationPrincipal String userId) {
        return shareLinksService.getByOwner(userId);
    }

    @PostMapping("/api/share-links")
    public ResponseEntity<ShareLinkEntity> create(
            @AuthenticationPrincipal String userId,
            @Valid @RequestBody CreateShareLinkRequest req) {
        return ResponseEntity.status(HttpStatus.CREATED).body(shareLinksService.create(userId, req));
    }

    @DeleteMapping("/api/share-links/{id}")
    public ResponseEntity<Void> delete(
            @AuthenticationPrincipal String userId,
            @PathVariable String id) {
        shareLinksService.delete(id, userId);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/api/s/{token}")
    public ResponseEntity<ShareLinksService.SharedView> view(@PathVariable String token) {
        return ResponseEntity.ok(shareLinksService.viewByToken(token));
    }

    @GetMapping("/api/s/{token}/content/{contentId}/media")
    public ResponseEntity<Resource> sharedMedia(
            @PathVariable String token,
            @PathVariable String contentId) {
        return shareLinksService.loadSharedMedia(token, contentId);
    }
}
