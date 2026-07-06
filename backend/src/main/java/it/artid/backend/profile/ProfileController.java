package it.artid.backend.profile;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/profile")
@RequiredArgsConstructor
public class ProfileController {

    private final ProfileService profileService;

    @GetMapping
    public ResponseEntity<StudentProfileEntity> getMyProfile(@AuthenticationPrincipal String userId) {
        return ResponseEntity.ok(profileService.get(userId));
    }

    @PutMapping
    public ResponseEntity<StudentProfileEntity> updateProfile(
            @AuthenticationPrincipal String userId,
            @RequestBody UpdateProfileRequest req) {
        return ResponseEntity.ok(profileService.update(userId, req));
    }

    @GetMapping("/{userId}")
    public ResponseEntity<StudentProfileEntity> getById(@PathVariable String userId) {
        return ResponseEntity.ok(profileService.get(userId));
    }
}
