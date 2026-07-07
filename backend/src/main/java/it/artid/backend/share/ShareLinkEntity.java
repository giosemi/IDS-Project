package it.artid.backend.share;

import jakarta.persistence.*;
import lombok.*;
import java.time.Instant;
import java.util.*;

@Entity
@Table(name = "share_links")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class ShareLinkEntity {
    @Id private String id;
    @Column(unique = true, nullable = false) private String token;
    @Column(nullable = false) private String ownerId;
    @Column(nullable = false) private String label;
    @ElementCollection(fetch = FetchType.EAGER)
    @CollectionTable(name = "share_link_content_ids", joinColumns = @JoinColumn(name = "link_id"))
    @Column(name = "content_id")
    @Builder.Default private List<String> contentIds = new ArrayList<>();
    private boolean includeProfile;
    @Column(nullable = false)
    @Builder.Default
    private boolean allowDownload = false;
    private Instant expiresAt;
    private int viewCount;
    private Instant lastViewedAt;

    public boolean isExpired() {
        return expiresAt != null && Instant.now().isAfter(expiresAt);
    }

    public String getShareUrl() {
        return "https://artid.afam.it/s/" + token;
    }
}
