package it.artid.backend.auth;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class OtpSentResponse {
    private boolean otpRequired;
    private String email;
    /** Solo in sviluppo, quando otp.expose-in-response=true */
    private String devOtp;
}
