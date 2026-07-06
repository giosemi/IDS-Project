package it.artid.backend.content;

import com.fasterxml.jackson.databind.ObjectMapper;
import it.artid.backend.auth.RegisterRequest;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.context.WebApplicationContext;

import static org.springframework.security.test.web.servlet.setup.SecurityMockMvcConfigurers.springSecurity;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@ActiveProfiles("test")
@Transactional
class ContentControllerTest {

    @Autowired WebApplicationContext wac;

    MockMvc mockMvc;
    final ObjectMapper objectMapper = new ObjectMapper();
    String token;

    @BeforeEach
    void setup() throws Exception {
        mockMvc = MockMvcBuilders.webAppContextSetup(wac)
                .apply(springSecurity())
                .build();

        var reg = new RegisterRequest();
        reg.setName("Test");
        reg.setEmail("content@test.it");
        reg.setPassword("pass123");
        var result = mockMvc.perform(post("/api/auth/register")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(reg)))
                .andReturn();
        token = objectMapper.readTree(result.getResponse().getContentAsString()).get("token").asText();
    }

    @Test
    void createContent_shouldReturn201() throws Exception {
        var req = new ContentRequest();
        req.setTitle("Sonata");
        req.setDescription("Descrizione");
        req.setYear(2024);
        req.setType(ContentType.AUDIO);
        req.setDuration("3:45");

        mockMvc.perform(post("/api/content")
                .header("Authorization", "Bearer " + token)
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(req)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.id").isNotEmpty())
                .andExpect(jsonPath("$.title").value("Sonata"))
                .andExpect(jsonPath("$.type").value("AUDIO"));
    }

    @Test
    void getContent_shouldReturnOwnedItems() throws Exception {
        var req = new ContentRequest();
        req.setTitle("Test Item");
        req.setDescription("Desc");
        req.setYear(2024);
        req.setType(ContentType.CV);
        mockMvc.perform(post("/api/content")
                .header("Authorization", "Bearer " + token)
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(req)));

        mockMvc.perform(get("/api/content")
                .header("Authorization", "Bearer " + token))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$").isArray())
                .andExpect(jsonPath("$[0].title").value("Test Item"));
    }

    @Test
    void deleteContent_shouldReturn204() throws Exception {
        var req = new ContentRequest();
        req.setTitle("Da eliminare");
        req.setDescription("Desc");
        req.setYear(2024);
        req.setType(ContentType.VIDEO);
        var result = mockMvc.perform(post("/api/content")
                .header("Authorization", "Bearer " + token)
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(req)))
                .andReturn();
        var item = objectMapper.readValue(result.getResponse().getContentAsString(), ContentItemEntity.class);

        mockMvc.perform(delete("/api/content/" + item.getId())
                .header("Authorization", "Bearer " + token))
                .andExpect(status().isNoContent());
    }

    @Test
    void createContent_noToken_shouldReturn401() throws Exception {
        var req = new ContentRequest();
        req.setTitle("X");
        req.setDescription("Y");
        req.setYear(2024);
        req.setType(ContentType.AUDIO);
        mockMvc.perform(post("/api/content")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(req)))
                .andExpect(status().isUnauthorized());
    }
}
