package it.artid.backend.profile;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "student_profiles")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class StudentProfileEntity {
    @Id private String userId;
    @Column(nullable = false) private String fullName;
    private String email;
    private String institution;
    private int studyYear;
    @Column(columnDefinition = "TEXT") private String bio;
}
