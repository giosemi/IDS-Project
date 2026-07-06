package it.artid.backend.content;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class ContentRequest {
    @NotBlank private String title;
    @NotBlank private String description;
    @NotNull  private Integer year;
    @NotNull  private ContentType type;
    private String technique;
    private String dimensions;
    private String duration;
    private String subtitle;
    private String fileName;
}
