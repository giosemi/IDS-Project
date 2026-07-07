package it.artid.backend.auth;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

@Service
@Slf4j
@RequiredArgsConstructor
public class OtpMailService {

    private final JavaMailSender mailSender;

    @Value("${spring.mail.username:}")
    private String mailUsername;

    @Value("${artid.mail.from:}")
    private String mailFrom;

    public void sendLoginOtp(String recipient, String code) {
        if (mailUsername == null || mailUsername.isBlank()) {
            log.warn("Email non configurata. OTP login per {}: {}", recipient, code);
            return;
        }

        try {
            var from = mailFrom == null || mailFrom.isBlank() ? mailUsername : mailFrom;
            var message = new SimpleMailMessage();
            message.setFrom(from);
            message.setTo(recipient);
            message.setSubject("ArtID — Codice di accesso");
            message.setText(buildBody(code));
            mailSender.send(message);
            log.info("OTP login inviato a {}", recipient);
        } catch (Exception ex) {
            log.error("Invio email OTP fallito per {}", recipient, ex);
            throw new IllegalStateException("Impossibile inviare l'email di verifica");
        }
    }

    private String buildBody(String code) {
        return """
                Ciao,

                Il tuo codice di accesso ArtID è: %s

                Il codice scade tra 5 minuti.

                Se non hai richiesto tu l'accesso, ignora questa email.

                — ArtID
                """.formatted(code);
    }
}
