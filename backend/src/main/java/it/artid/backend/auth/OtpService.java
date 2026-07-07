package it.artid.backend.auth;

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

    private final OtpMailService mailService;
    private final SecureRandom random = new SecureRandom();
    private final Map<String, OtpEntry> pendingByEmail = new ConcurrentHashMap<>();

    @Value("${otp.fixed-code:}")
    private String fixedCode;

    public String sendLoginOtp(UserEntity user) {
        var email = user.getEmail().toLowerCase();
        var code = generateCode();
        pendingByEmail.put(email, new OtpEntry(user.getId(), code, Instant.now().plusSeconds(OTP_TTL_SECONDS)));
        mailService.sendLoginOtp(email, code);
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

    private String generateCode() {
        if (fixedCode != null && !fixedCode.isBlank()) {
            return fixedCode.trim();
        }
        return String.format("%05d", random.nextInt(100_000));
    }

    private record OtpEntry(String userId, String code, Instant expiresAt) {}
}
