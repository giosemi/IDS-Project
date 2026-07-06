package it.artid.backend.profile;

import lombok.Data;

import java.util.List;

@Data
public class UpdateProfileRequest {
    private String fullName;
    private String institution;
    private String course;
    private Integer studyYear;
    private String bio;
    private List<String> skills;
    private String cvSummary;
}
