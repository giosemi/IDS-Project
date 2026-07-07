package it.artid.backend.profile;

import lombok.Data;

@Data
public class UpdateProfileRequest {
    private String fullName;
    private String institution;
    private Integer studyYear;
    private String bio;
}
