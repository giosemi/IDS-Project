package it.artid.backend.profile;



import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;


public class ProfileStore {

    public record StudentProfile(
            String userId,
            String fullName,
            String email,
            String institution,
            String course,
            int studyYear,
            String bio,
            List<String> skills,
            String cvSummary
    ) {}

    private final Map<String, StudentProfile> profiles = new ConcurrentHashMap<>();

    public void init(String userId, String name, String email) {
        profiles.put(userId, new StudentProfile(userId, name, email, "", "", 1, "", List.of(), null));
    }

    public StudentProfile get(String userId) {
        return profiles.get(userId);
    }

    public StudentProfile update(String userId, UpdateProfileRequest req) {
        var existing = profiles.getOrDefault(userId,
                new StudentProfile(userId, "", "", "", "", 1, "", List.of(), null));
        var updated = new StudentProfile(
                userId,
                req.getFullName()    != null ? req.getFullName()    : existing.fullName(),
                existing.email(),
                req.getInstitution() != null ? req.getInstitution() : existing.institution(),
                req.getCourse()      != null ? req.getCourse()      : existing.course(),
                req.getStudyYear()   != null ? req.getStudyYear()   : existing.studyYear(),
                req.getBio()         != null ? req.getBio()         : existing.bio(),
                req.getSkills()      != null ? req.getSkills()      : existing.skills(),
                req.getCvSummary()   != null ? req.getCvSummary()   : existing.cvSummary()
        );
        profiles.put(userId, updated);
        return updated;
    }
}
