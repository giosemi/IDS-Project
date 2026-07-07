package it.artid.backend.content;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.Resource;
import org.springframework.core.io.UrlResource;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.server.ResponseStatusException;

import java.io.IOException;
import java.net.MalformedURLException;
import java.nio.file.Files;
import java.nio.file.Path;

@Service
@Slf4j
public class ContentStorageService {

    private final Path uploadDir;

    public ContentStorageService(@Value("${artid.upload-dir:uploads}") String uploadDir) {
        this.uploadDir = Path.of(uploadDir).toAbsolutePath().normalize();
    }

    public void store(String contentId, MultipartFile file) {
        if (file == null || file.isEmpty()) return;
        try {
            Files.createDirectories(uploadDir);
            var target = resolvePath(contentId);
            file.transferTo(target);
            log.info("File salvato per contenuto {}", contentId);
        } catch (IOException ex) {
            throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "Impossibile salvare il file");
        }
    }

    public boolean exists(String contentId) {
        return Files.exists(resolvePath(contentId));
    }

    public Resource load(String contentId) {
        if (!exists(contentId)) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "File non trovato");
        }
        try {
            var resource = new UrlResource(resolvePath(contentId).toUri());
            if (!resource.exists() || !resource.isReadable()) {
                throw new ResponseStatusException(HttpStatus.NOT_FOUND, "File non trovato");
            }
            return resource;
        } catch (MalformedURLException ex) {
            throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "File non accessibile");
        }
    }

    public void delete(String contentId) {
        try {
            Files.deleteIfExists(resolvePath(contentId));
        } catch (IOException ex) {
            log.warn("Impossibile eliminare il file per {}", contentId, ex);
        }
    }

    private Path resolvePath(String contentId) {
        return uploadDir.resolve(contentId);
    }
}
