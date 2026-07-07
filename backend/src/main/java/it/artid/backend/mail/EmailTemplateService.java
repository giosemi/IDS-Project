package it.artid.backend.mail;

import org.springframework.core.io.ClassPathResource;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@Service
public class EmailTemplateService {

    private static final Pattern PLACEHOLDER = Pattern.compile("\\{\\{([a-zA-Z0-9_]+)\\}\\}");

    public String renderHtml(String templateName, Map<String, String> variables) {
        return render(load(templateName + ".html"), variables);
    }

    public String renderText(String templateName, Map<String, String> variables) {
        return render(load(templateName + ".txt"), variables);
    }

    private String load(String filename) {
        var resource = new ClassPathResource("templates/email/" + filename);
        try (var input = resource.getInputStream()) {
            return new String(input.readAllBytes(), StandardCharsets.UTF_8);
        } catch (IOException ex) {
            throw new IllegalStateException("Template email non trovato: " + filename, ex);
        }
    }

    private String render(String template, Map<String, String> variables) {
        var matcher = PLACEHOLDER.matcher(template);
        var result = new StringBuffer();
        while (matcher.find()) {
            var key = matcher.group(1);
            var value = variables.getOrDefault(key, "");
            matcher.appendReplacement(result, Matcher.quoteReplacement(value));
        }
        matcher.appendTail(result);
        return result.toString();
    }
}
