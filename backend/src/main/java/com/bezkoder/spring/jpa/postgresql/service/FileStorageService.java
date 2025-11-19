package com.bezkoder.spring.jpa.postgresql.service;

import software.amazon.awssdk.services.s3.model.NoSuchKeyException;
import com.bezkoder.spring.jpa.postgresql.config.FileNotFoundException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.InputStreamResource;
import org.springframework.core.io.Resource;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import org.springframework.web.multipart.MultipartFile;
import software.amazon.awssdk.core.sync.RequestBody;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.GetObjectRequest;
import software.amazon.awssdk.services.s3.model.PutObjectRequest;
import software.amazon.awssdk.services.s3.model.S3Exception;
import software.amazon.awssdk.core.ResponseInputStream;
import software.amazon.awssdk.services.s3.model.GetObjectResponse;
import software.amazon.awssdk.services.s3.model.DeleteObjectRequest;

import java.io.IOException;
import java.util.Objects;
// ===================================================


@Service
public class FileStorageService {

    private final S3Client s3Client;
    private final String bucketName;

    @Autowired
    public FileStorageService(S3Client s3Client, @Value("${S3_BUCKET}") String bucketName) {
        this.s3Client = s3Client;
        this.bucketName = bucketName;
        // NIE potrzebujemy już Files.createDirectories()!
    }

    /**
     * Zapisuje plik w S3 i zwraca jego unikalny klucz (nazwę).
     */
    public String storeFile(MultipartFile file) throws IOException {
        // Generuje unikalną nazwę pliku, aby uniknąć nadpisania
        String filename = System.currentTimeMillis() + "_" + StringUtils.cleanPath(Objects.requireNonNull(file.getOriginalFilename()));

        try {
            PutObjectRequest putObjectRequest = PutObjectRequest.builder()
                    .bucket(bucketName)
                    .key(filename)
                    .contentType(file.getContentType())
                    .build();

            s3Client.putObject(putObjectRequest, 
                    RequestBody.fromInputStream(file.getInputStream(), file.getSize()));

            return filename; // Zwraca klucz pliku w S3
            
        } catch (S3Exception | IOException e) {
            throw new IOException("Nie można zapisać pliku w S3: " + e.getMessage(), e);
        }
    }

/**
     * Ładuje plik z S3 jako zasób (Resource), który można strumieniować.
     * Obsługuje różne wersje pliku (oryginał vs. miniaturka).
     */
    public Resource loadFile(String filename, String version) {
        
        String s3Key;
        if ("thumbnail".equals(version)) {
            s3Key = "thumbnails/" + filename;
        } else {
            s3Key = filename; 
        }

        try {
            GetObjectRequest getObjectRequest = GetObjectRequest.builder()
                    .bucket(bucketName)
                    .key(s3Key)
                    .build();

            ResponseInputStream<GetObjectResponse> s3Object = s3Client.getObject(getObjectRequest);

            return new InputStreamResource(s3Object);
            
        } catch (NoSuchKeyException e) {
            // ↓↓↓ NAJWAŻNIEJSZA ZMIANA ↓↓↓
            // S3 rzuciło 'NoSuchKeyException' - pliku nie ma.
            // Rzucamy nasz własny wyjątek, który Spring zamieni na 404.
            throw new FileNotFoundException("Nie znaleziono pliku w S3: " + s3Key, e);

        } catch (S3Exception e) {
            // Wystąpił inny, nieoczekiwany błąd S3 (np. brak uprawnień)
            // To jest błąd 500
            throw new RuntimeException("Nie można odczytać pliku z S3: " + s3Key, e);
        }
    }

    public void deleteFile(String filename) {
        if (filename == null || filename.isEmpty()) {
            return; // Nic do zrobienia
        }
        
        try {
            DeleteObjectRequest deleteObjectRequest = DeleteObjectRequest.builder()
                    .bucket(bucketName)
                    .key(filename)
                    .build();

            s3Client.deleteObject(deleteObjectRequest);

        } catch (S3Exception e) {
            // Logowanie błędu byłoby dobre, ale na razie rzucamy wyjątek
            throw new RuntimeException("Nie można usunąć pliku z S3: " + filename, e);
        }
    }
}