package it.artid.backend.auth;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    @PostMapping("/register")
    public ResponseEntity<AuthResponse> register(@Valid @RequestBody RegisterRequest req) {
        return ResponseEntity.status(HttpStatus.CREATED).body(authService.register(req));
    }

    @PostMapping("/login")
    public ResponseEntity<OtpSentResponse> login(@Valid @RequestBody LoginRequest req) {
        return ResponseEntity.ok(authService.initiateLogin(req));
    }

    @PostMapping("/verify-otp")
    public ResponseEntity<AuthResponse> verifyOtp(@Valid @RequestBody VerifyOtpRequest req) {
        return ResponseEntity.ok(authService.verifyLoginOtp(req));
    }

    @PostMapping("/resend-otp")
    public ResponseEntity<OtpSentResponse> resendOtp(@Valid @RequestBody ResendOtpRequest req) {
        return ResponseEntity.ok(authService.resendLoginOtp(req));
    }
}
