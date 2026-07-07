package it.artid.backend.auth;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class VerifyOtpRequest {
    @Email @NotBlank private String email;
    @NotBlank @Size(min = 5, max = 5) private String code;
}
