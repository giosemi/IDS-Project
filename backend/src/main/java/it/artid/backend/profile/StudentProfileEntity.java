package it.artid.backend.profile;

import jakarta.persistence.*;
import lombok.*;
import java.util.*;

@Entity
@Table(name = "student_profiles")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class StudentProfileEntity {
    @Id private String userId;
    @Column(nullable = false) private String fullName;
    private String email;
    private String institution;
    private String course;
    private int studyYear;
    @Column(columnDefinition = "TEXT") private String bio;
    @ElementCollection(fetch = FetchType.EAGER)
    @CollectionTable(name = "profile_skills", joinColumns = @JoinColumn(name = "user_id"))
    @Column(name = "skill")
    @Builder.Default private List<String> skills = new ArrayList<>();
    @Column(columnDefinition = "TEXT") private String cvSummary;
}
