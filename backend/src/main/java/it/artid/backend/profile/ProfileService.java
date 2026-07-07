package it.artid.backend.profile;

import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

@Service
@RequiredArgsConstructor
public class ProfileService {

    private final ProfileRepository profileRepository;

    public StudentProfileEntity get(String userId) {
        return profileRepository.findById(userId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Profilo non trovato"));
    }

    @Transactional
    public StudentProfileEntity update(String userId, UpdateProfileRequest req) {
        var profile = profileRepository.findById(userId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Profilo non trovato"));
        if (req.getFullName()    != null) profile.setFullName(req.getFullName());
        if (req.getInstitution() != null) profile.setInstitution(req.getInstitution());
        if (req.getCourse()      != null) profile.setCourse(req.getCourse());
        if (req.getStudyYear()   != null) profile.setStudyYear(req.getStudyYear());
        if (req.getBio()         != null) profile.setBio(req.getBio());
        return profileRepository.save(profile);
    }
}
