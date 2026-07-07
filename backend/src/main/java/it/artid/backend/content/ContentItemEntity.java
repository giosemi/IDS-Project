package it.artid.backend.content;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "content_items")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class ContentItemEntity {
    @Id private String id;
    @Column(nullable = false) private String title;
    @Column(columnDefinition = "TEXT") private String description;
    @Column(name = "release_year") private int year;
    @Column(nullable = false) private String ownerId;
    @Enumerated(EnumType.STRING) @Column(nullable = false) private ContentType type;
    private String technique;
    private String dimensions;
    private String duration;
    private String subtitle;
    private String fileName;

    @Transient
    private boolean hasMedia;
}
