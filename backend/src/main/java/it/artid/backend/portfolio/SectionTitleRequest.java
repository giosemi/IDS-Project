package it.artid.backend.portfolio;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class SectionTitleRequest {
    @NotBlank private String title;
}
