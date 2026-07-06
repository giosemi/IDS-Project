package it.artid.backend.auth;

import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

public class InMemoryUserStore {

    public record UserRecord(String id, String name, String email, String passwordHash) {}

    private final Map<String, UserRecord> users = new ConcurrentHashMap<>();

    public boolean existsByEmail(String email) {
        return users.containsKey(email.toLowerCase());
    }

    public UserRecord create(String name, String email, String passwordHash) {
        var user = new UserRecord(UUID.randomUUID().toString(), name, email.toLowerCase(), passwordHash);
        users.put(email.toLowerCase(), user);
        return user;
    }

    public UserRecord findByEmail(String email) {
        return users.get(email.toLowerCase());
    }
}
