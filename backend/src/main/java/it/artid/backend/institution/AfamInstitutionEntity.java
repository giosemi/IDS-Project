package it.artid.backend.institution;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.*;

@Entity
@Table(name = "afam_institutions")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AfamInstitutionEntity {
    @Id
    private String id;

    @Column(nullable = false, unique = true)
    private String name;

    @Column(nullable = false)
    private String city;
}
