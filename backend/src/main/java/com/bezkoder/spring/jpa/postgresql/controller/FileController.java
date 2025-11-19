package com.bezkoder.spring.jpa.postgresql.controller;

// Usunięto importy dla ResourceNotFoundException, MalformedURLException, Path i UrlResource
import com.bezkoder.spring.jpa.postgresql.service.FileStorageService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.Resource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import java.io.IOException;

@CrossOrigin(origins = "http://localhost:8081")
@RestController
@RequestMapping("/api/files")
public class FileController {

    @Autowired
    private FileStorageService fileStorageService;

    /**
     * Ta metoda pozostała bez zmian.
     * fileStorageService.storeFile() nadal przyjmuje MultipartFile i zwraca String (klucz pliku).
     */
    @PostMapping("/upload")
    public ResponseEntity<String> uploadFile(@RequestParam("file") MultipartFile file) throws IOException {
        String filename = fileStorageService.storeFile(file);
        return ResponseEntity.ok(filename); // zwraca klucz pliku S3
    }

    /**
     * Ta metoda została uproszczona, aby współpracować z S3.
     */
    @GetMapping("/{filename}")
    public ResponseEntity<Resource> getFile(@PathVariable String filename, @RequestParam(name = "version", defaultValue = "original") String version) {
        
        // 1. Nowy serwis zwraca bezpośrednio 'Resource', a nie 'Path'
        Resource resource = fileStorageService.loadFile(filename, version);
        // 2. Usunięto sprawdzanie 'filePath.toFile().exists()' i 'UrlResource'.
        // Jeśli plik nie istnieje w S3, 'loadFile' rzuci wyjątek, 
        // który Spring automatycznie zamieni na błąd 404 lub 500.

        // 3. Zwracamy zasób bezpośrednio. Spring wie, jak strumieniować go z S3.
        return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_OCTET_STREAM) // Wymusza pobieranie pliku
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"" + filename + "\"")
                .body(resource);
    }
}