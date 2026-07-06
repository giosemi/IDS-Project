package it.artid.backend.portfolio;

import jakarta.persistence.*;
import lombok.*;
import java.util.*;

@Entity
@Table(name = "portfolio_sections")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class PortfolioSectionEntity {
    @Id private String id;
    @Column(nullable = false) private String userId;
    @Column(nullable = false) private String title;
    private int displayOrder;
    @ElementCollection(fetch = FetchType.EAGER)
    @CollectionTable(name = "section_content_ids", joinColumns = @JoinColumn(name = "section_id"))
    @OrderColumn(name = "content_order")
    @Column(name = "content_id")
    @Builder.Default private List<String> contentIds = new ArrayList<>();
}
