package it.artid.backend.mail;

import jakarta.mail.internet.MimeMessage;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;

import java.nio.charset.StandardCharsets;
import java.util.Map;

@Service
@Slf4j
@RequiredArgsConstructor
public class AuthMailService {

    private final JavaMailSender mailSender;
    private final EmailTemplateService templates;

    @Value("${spring.mail.username:}")
    private String mailUsername;

    @Value("${artid.mail.from:}")
    private String mailFrom;

    public void sendLoginOtp(String recipient, String fullName, String code) {
        send(
                "login-otp",
                "ArtID — Codice di accesso",
                recipient,
                Map.of(
                        "fullName", fullName,
                        "code", code
                ),
                true
        );
    }

    public void sendPasswordResetOtp(String recipient, String code) {
        send(
                "password-reset",
                "ArtID — Recupero password",
                recipient,
                Map.of("code", code),
                true
        );
    }

    private void send(
            String templateName,
            String subject,
            String recipient,
            Map<String, String> variables,
            boolean failOnError
    ) {
        if (mailUsername == null || mailUsername.isBlank()) {
            log.warn("Email non configurata. Template {} per {}: {}", templateName, recipient, variables);
            return;
        }

        try {
            var from = mailFrom == null || mailFrom.isBlank() ? mailUsername : mailFrom;
            var textBody = templates.renderText(templateName, variables);
            var htmlBody = templates.renderHtml(templateName, variables);

            MimeMessage message = mailSender.createMimeMessage();
            var helper = new MimeMessageHelper(message, true, StandardCharsets.UTF_8.name());
            helper.setFrom(from);
            helper.setTo(recipient);
            helper.setSubject(subject);
            helper.setText(textBody, htmlBody);
            mailSender.send(message);
            log.info("Email {} inviata a {}", templateName, recipient);
        } catch (Exception ex) {
            log.error("Invio email {} fallito per {}", templateName, recipient, ex);
            if (failOnError) {
                throw new IllegalStateException("Impossibile inviare l'email");
            }
        }
    }
}
