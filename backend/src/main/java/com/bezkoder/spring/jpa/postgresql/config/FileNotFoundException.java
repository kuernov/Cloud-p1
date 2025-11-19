package com.bezkoder.spring.jpa.postgresql.config; // Upewnij się, że pakiet pasuje

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ResponseStatus;

/**
 * Ten wyjątek, gdy zostanie rzucony z kontrolera lub serwisu,
 * automatycznie sprawi, że Spring Boot zwróci odpowiedź 404 Not Found.
 */
@ResponseStatus(HttpStatus.NOT_FOUND)
public class FileNotFoundException extends RuntimeException {
    public FileNotFoundException(String message) {
        super(message);
    }

    public FileNotFoundException(String message, Throwable cause) {
        super(message, cause);
    }
}