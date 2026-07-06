package it.artid.backend.auth;

import it.artid.backend.profile.ProfileRepository;
import it.artid.backend.profile.StudentProfileEntity;
import it.artid.backend.security.JwtService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.util.ArrayList;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserRepository userRepository;
    private final ProfileRepository profileRepository;
    private final JwtService jwtService;
    private final PasswordEncoder passwordEncoder;

    @Transactional
    public AuthResponse register(RegisterRequest req) {
        if (userRepository.existsByEmailIgnoreCase(req.getEmail())) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Email già registrata");
        }
        var user = UserEntity.builder()
                .id(UUID.randomUUID().toString())
                .name(req.getName().trim())
                .email(req.getEmail().toLowerCase())
                .passwordHash(passwordEncoder.encode(req.getPassword()))
                .build();
        userRepository.save(user);

        var profile = StudentProfileEntity.builder()
                .userId(user.getId())
                .fullName(user.getName())
                .email(user.getEmail())
                .institution("").course("").studyYear(1).bio("")
                .skills(new ArrayList<>())
                .build();
        profileRepository.save(profile);

        return buildResponse(user);
    }

    public AuthResponse login(LoginRequest req) {
        var user = userRepository.findByEmailIgnoreCase(req.getEmail())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Credenziali non valide"));
        if (!passwordEncoder.matches(req.getPassword(), user.getPasswordHash())) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Credenziali non valide");
        }
        return buildResponse(user);
    }

    private AuthResponse buildResponse(UserEntity user) {
        String token = jwtService.generateToken(user.getId());
        return new AuthResponse(token, new AuthResponse.UserDto(user.getId(), user.getName(), user.getEmail()));
    }
}
