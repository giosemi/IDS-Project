package it.artid.backend.auth;

import it.artid.backend.profile.ProfileRepository;
import it.artid.backend.profile.StudentProfileEntity;
import it.artid.backend.security.JwtService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.util.UUID;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserRepository userRepository;
    private final ProfileRepository profileRepository;
    private final JwtService jwtService;
    private final PasswordEncoder passwordEncoder;
    private final OtpService otpService;

    @Value("${otp.expose-in-response:false}")
    private boolean exposeOtpInResponse;

    @Value("${spring.mail.username:}")
    private String mailUsername;

    @Transactional
    public AuthResponse register(RegisterRequest req) {
        if (userRepository.existsByEmailIgnoreCase(req.getEmail())) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Email già registrata");
        }
        var fullName = "%s %s".formatted(req.getFirstName().trim(), req.getLastName().trim());
        var user = UserEntity.builder()
                .id(UUID.randomUUID().toString())
                .name(fullName)
                .email(req.getEmail().toLowerCase())
                .passwordHash(passwordEncoder.encode(req.getPassword()))
                .build();
        userRepository.save(user);

        var profile = StudentProfileEntity.builder()
                .userId(user.getId())
                .fullName(fullName)
                .email(user.getEmail())
                .institution(req.getInstitution().trim()).studyYear(1).bio("")
                .build();
        profileRepository.save(profile);

        return buildResponse(user);
    }

    public OtpSentResponse initiateLogin(LoginRequest req) {
        var user = authenticate(req.getEmail(), req.getPassword());
        var code = otpService.sendLoginOtp(user);
        return new OtpSentResponse(true, user.getEmail(), devOtpOrNull(code));
    }

    public AuthResponse verifyLoginOtp(VerifyOtpRequest req) {
        var userId = otpService.consumeValidOtp(req.getEmail(), req.getCode());
        var user = userRepository.findById(userId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Codice OTP non valido o scaduto"));
        return buildResponse(user);
    }

    public OtpSentResponse resendLoginOtp(ResendOtpRequest req) {
        var user = userRepository.findByEmailIgnoreCase(req.getEmail())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Utente non trovato"));
        var code = otpService.resendLoginOtp(req.getEmail(), user);
        return new OtpSentResponse(true, user.getEmail(), devOtpOrNull(code));
    }

    public OtpSentResponse forgotPassword(ForgotPasswordRequest req) {
        var email = req.getEmail().toLowerCase();
        var userOpt = userRepository.findByEmailIgnoreCase(email);
        if (userOpt.isPresent()) {
            var code = otpService.sendPasswordResetOtp(userOpt.get());
            return new OtpSentResponse(true, email, devOtpOrNull(code));
        }
        return new OtpSentResponse(true, email, null);
    }

    @Transactional
    public MessageResponse resetPassword(ResetPasswordRequest req) {
        var userId = otpService.consumePasswordResetOtp(req.getEmail(), req.getCode());
        var user = userRepository.findById(userId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Codice non valido o scaduto"));
        user.setPasswordHash(passwordEncoder.encode(req.getNewPassword()));
        userRepository.save(user);
        return new MessageResponse("Password aggiornata con successo");
    }

    private UserEntity authenticate(String email, String password) {
        var user = userRepository.findByEmailIgnoreCase(email)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Credenziali non valide"));
        if (!passwordEncoder.matches(password, user.getPasswordHash())) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Credenziali non valide");
        }
        return user;
    }

    private AuthResponse buildResponse(UserEntity user) {
        String token = jwtService.generateToken(user.getId());
        return new AuthResponse(token, new AuthResponse.UserDto(user.getId(), user.getName(), user.getEmail()));
    }

    private String devOtpOrNull(String code) {
        if (!exposeOtpInResponse) return null;
        if (mailUsername != null && !mailUsername.isBlank()) return null;
        return code;
    }
}
