package it.artid.backend.auth;

import it.artid.backend.mail.AuthMailService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.security.SecureRandom;
import java.time.Instant;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@Service
@RequiredArgsConstructor
public class OtpService {

    private static final int OTP_TTL_SECONDS = 300;

    private final AuthMailService mailService;
    private final SecureRandom random = new SecureRandom();
    private final Map<String, OtpEntry> pendingByEmail = new ConcurrentHashMap<>();
    private final Map<String, OtpEntry> passwordResetByEmail = new ConcurrentHashMap<>();

    @Value("${otp.fixed-code:}")
    private String fixedCode;

    public String sendLoginOtp(UserEntity user) {
        var email = user.getEmail().toLowerCase();
        var code = generateCode();
        pendingByEmail.put(email, new OtpEntry(user.getId(), code, Instant.now().plusSeconds(OTP_TTL_SECONDS)));
        mailService.sendLoginOtp(email, user.getName(), code);
        return code;
    }

    public String consumeValidOtp(String email, String code) {
        var entry = pendingByEmail.get(email.toLowerCase());
        if (entry == null) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Codice OTP non valido o scaduto");
        }
        if (Instant.now().isAfter(entry.expiresAt())) {
            pendingByEmail.remove(email.toLowerCase());
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Codice OTP non valido o scaduto");
        }
        if (!entry.code().equals(code.trim())) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Codice OTP non valido o scaduto");
        }
        pendingByEmail.remove(email.toLowerCase());
        return entry.userId();
    }

    public String resendLoginOtp(String email, UserEntity user) {
        if (!user.getEmail().equalsIgnoreCase(email)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Email non valida");
        }
        return sendLoginOtp(user);
    }

    public String sendPasswordResetOtp(UserEntity user) {
        var email = user.getEmail().toLowerCase();
        var code = generateCode();
        passwordResetByEmail.put(email, new OtpEntry(user.getId(), code, Instant.now().plusSeconds(OTP_TTL_SECONDS)));
        mailService.sendPasswordResetOtp(email, code);
        return code;
    }

    public String consumePasswordResetOtp(String email, String code) {
        var entry = passwordResetByEmail.get(email.toLowerCase());
        if (entry == null) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Codice non valido o scaduto");
        }
        if (Instant.now().isAfter(entry.expiresAt())) {
            passwordResetByEmail.remove(email.toLowerCase());
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Codice non valido o scaduto");
        }
        if (!entry.code().equals(code.trim())) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Codice non valido o scaduto");
        }
        passwordResetByEmail.remove(email.toLowerCase());
        return entry.userId();
    }

    private String generateCode() {
        if (fixedCode != null && !fixedCode.isBlank()) {
            return fixedCode.trim();
        }
        return String.format("%05d", random.nextInt(100_000));
    }

    private record OtpEntry(String userId, String code, Instant expiresAt) {}
}
