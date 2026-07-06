package it.artid.backend.search;

import it.artid.backend.content.ContentItemEntity;
import it.artid.backend.content.ContentService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/search")
@RequiredArgsConstructor
public class SearchController {

    private final ContentService contentService;

    @GetMapping
    public List<ContentItemEntity> search(@RequestParam String q) {
        return contentService.search(q);
    }
}
