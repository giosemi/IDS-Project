package it.artid.backend.share;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import lombok.Data;

import java.time.Instant;
import java.util.List;

@Data
public class CreateShareLinkRequest {
    @NotBlank  private String label;
    @NotEmpty  private List<String> contentIds;
    private boolean includeProfile = true;
    private Instant expiresAt;
}
