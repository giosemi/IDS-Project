package it.artid.backend.share;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.time.Instant;
import java.util.ArrayList;
import java.util.List;

@Data
public class CreateShareLinkRequest {
    @NotBlank private String label;
    @NotNull private List<String> contentIds = new ArrayList<>();
    private boolean includeProfile = true;
    private boolean allowDownload = false;
    private Instant expiresAt;
}
