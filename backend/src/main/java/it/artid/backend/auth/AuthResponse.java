package it.artid.backend.auth;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class AuthResponse {
    private String token;
    private UserDto user;

    @Data
    @AllArgsConstructor
    public static class UserDto {
        private String id;
        private String name;
        private String email;
    }
}
