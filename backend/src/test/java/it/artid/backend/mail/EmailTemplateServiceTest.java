package it.artid.backend.mail;

import org.junit.jupiter.api.Test;

import java.util.Map;

import static org.junit.jupiter.api.Assertions.*;

class EmailTemplateServiceTest {

    private final EmailTemplateService service = new EmailTemplateService();

    @Test
    void renderPasswordReset_shouldReplaceCode() {
        var text = service.renderText(
                "password-reset",
                Map.of("code", "54321")
        );

        assertTrue(text.contains("54321"));
    }

    @Test
    void renderLoginOtp_shouldReplaceCode() {
        var text = service.renderText(
                "login-otp",
                Map.of("fullName", "Anna", "code", "12345")
        );

        assertTrue(text.contains("12345"));
        assertTrue(text.contains("Anna"));
    }
}
