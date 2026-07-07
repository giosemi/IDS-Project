package it.artid.backend.content;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.core.io.Resource;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

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

    @PostMapping(consumes = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<ContentItemEntity> createJson(
            @AuthenticationPrincipal String userId,
            @Valid @RequestBody ContentRequest req) {
        return ResponseEntity.status(HttpStatus.CREATED).body(contentService.create(userId, req, null));
    }

    @PostMapping(consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<ContentItemEntity> createMultipart(
            @AuthenticationPrincipal String userId,
            @Valid @RequestPart("data") ContentRequest req,
            @RequestPart(value = "file", required = false) MultipartFile file) {
        return ResponseEntity.status(HttpStatus.CREATED).body(contentService.create(userId, req, file));
    }

    @PutMapping(value = "/{id}", consumes = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<ContentItemEntity> updateJson(
            @AuthenticationPrincipal String userId,
            @PathVariable String id,
            @RequestBody ContentRequest req) {
        return ResponseEntity.ok(contentService.update(id, userId, req, null));
    }

    @PutMapping(value = "/{id}", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<ContentItemEntity> updateMultipart(
            @AuthenticationPrincipal String userId,
            @PathVariable String id,
            @RequestPart("data") ContentRequest req,
            @RequestPart(value = "file", required = false) MultipartFile file) {
        return ResponseEntity.ok(contentService.update(id, userId, req, file));
    }

    @GetMapping("/{id}/media")
    public ResponseEntity<Resource> getMedia(
            @AuthenticationPrincipal String userId,
            @PathVariable String id) {
        return contentService.loadMedia(id, userId);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(
            @AuthenticationPrincipal String userId,
            @PathVariable String id) {
        contentService.delete(id, userId);
        return ResponseEntity.noContent().build();
    }
}
