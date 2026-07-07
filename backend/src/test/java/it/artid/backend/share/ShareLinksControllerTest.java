package it.artid.backend.share;

import com.fasterxml.jackson.databind.ObjectMapper;
import it.artid.backend.auth.RegisterRequest;
import it.artid.backend.content.ContentRequest;
import it.artid.backend.content.ContentType;
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
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@ActiveProfiles("test")
@Transactional
class ShareLinksControllerTest {

    @Autowired WebApplicationContext wac;

    MockMvc mockMvc;
    final ObjectMapper objectMapper = new ObjectMapper();
    String token;
    String contentId;

    @BeforeEach
    void setup() throws Exception {
        mockMvc = MockMvcBuilders.webAppContextSetup(wac)
                .apply(springSecurity())
                .build();

        var reg = new RegisterRequest();
        reg.setFirstName("Share");
        reg.setLastName("Test");
        reg.setEmail("share-links@test.it");
        reg.setPassword("pass123");
        reg.setInstitution("Accademia di Brera");
        var result = mockMvc.perform(post("/api/auth/register")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(reg)))
                .andReturn();
        token = objectMapper.readTree(result.getResponse().getContentAsString()).get("token").asText();

        var contentReq = new ContentRequest();
        contentReq.setTitle("Opera");
        contentReq.setDescription("Desc");
        contentReq.setYear(2024);
        contentReq.setType(ContentType.AUDIO);
        var contentResult = mockMvc.perform(post("/api/content")
                .header("Authorization", "Bearer " + token)
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(contentReq)))
                .andReturn();
        contentId = objectMapper.readTree(contentResult.getResponse().getContentAsString()).get("id").asText();
    }

    @Test
    void sharedTokenEndpoint_shouldBePublic() throws Exception {
        mockMvc.perform(get("/api/s/unknown-token"))
                .andExpect(status().isNotFound());
    }

    @Test
    void shareLinksEndpoint_shouldNotBePublic() throws Exception {
        mockMvc.perform(get("/api/share-links"))
                .andExpect(status().isUnauthorized());
    }

    @Test
    void createShareLink_shouldReturn201() throws Exception {
        mockMvc.perform(post("/api/share-links")
                .header("Authorization", "Bearer " + token)
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                        {
                          "label": "Audizione",
                          "contentIds": ["%s"],
                          "includeProfile": true,
                          "allowDownload": false,
                          "expiresAt": "2026-12-31T23:59:59Z"
                        }
                        """.formatted(contentId)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.id").isNotEmpty())
                .andExpect(jsonPath("$.label").value("Audizione"))
                .andExpect(jsonPath("$.allowDownload").value(false));
    }

    @Test
    void getShareLinks_shouldReturn200() throws Exception {
        mockMvc.perform(get("/api/share-links")
                .header("Authorization", "Bearer " + token))
                .andExpect(status().isOk());
    }
}
