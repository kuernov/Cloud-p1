package com.bezkoder.spring.jpa.postgresql.service;

import com.bezkoder.spring.jpa.postgresql.config.ResourceNotFoundException;
import com.bezkoder.spring.jpa.postgresql.model.Tutorial;
import com.bezkoder.spring.jpa.postgresql.repository.TutorialRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

// Importy Path i Files zostały usunięte
import java.io.IOException; // IOException jest nadal potrzebne dla 'createTutorial' jeśli ten zostanie rozbudowany, ale usuwamy je z delete
import java.util.List;

@Service
public class TutorialService {

    @Autowired
    private TutorialRepository tutorialRepository;

    @Autowired
    private FileStorageService fileStorageService; // Ten serwis potrafi już usuwać z S3

    // Tworzenie tutoriala przy podanej nazwie pliku
    public Tutorial createTutorial(String title, String description, String imagePath) {
        Tutorial tutorial = new Tutorial();
        tutorial.setTitle(title);
        tutorial.setDescription(description);
        tutorial.setPublished(false);
        tutorial.setImagePath(imagePath); // Zapisujemy tylko klucz/nazwę pliku z S3
        return tutorialRepository.save(tutorial);
    }

    public Tutorial updateTutorial(long id, Tutorial tutorialData) {
        Tutorial tutorial = tutorialRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Tutorial not found with id " + id));

        tutorial.setTitle(tutorialData.getTitle());
        tutorial.setDescription(tutorialData.getDescription());
        tutorial.setPublished(tutorialData.isPublished());
        return tutorialRepository.save(tutorial);
    }

    // --- POPRAWKA TUTAJ ---
    // Usunięto 'throws IOException'
    public void deleteTutorial(long id) {
        Tutorial tutorial = tutorialRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Tutorial not found with id " + id));

        if (tutorial.getImagePath() != null) {
            // Zamiast Path i Files.delete, wywołujemy naszą nową metodę z serwisu S3
            fileStorageService.deleteFile(tutorial.getImagePath());
        }
        tutorialRepository.deleteById(id);
    }

    // --- POPRAWKA TUTAJ ---
    // Usunięto 'throws IOException'
    public void deleteAllTutorials() {
        // najpierw usuń wszystkie pliki z S3
        for (Tutorial t : tutorialRepository.findAll()) {
            if (t.getImagePath() != null) {
                 // Zamiast Path i Files.delete, wywołujemy naszą nową metodę z serwisu S3
                fileStorageService.deleteFile(t.getImagePath());
            }
        }
        tutorialRepository.deleteAll();
    }

    public List<Tutorial> getAllTutorials(String title) {
        return (title == null) ? tutorialRepository.findAll() : tutorialRepository.findByTitleContaining(title);
    }

    public List<Tutorial> getPublishedTutorials() {
        return tutorialRepository.findByPublished(true);
    }

    public Tutorial getTutorialById(long id) {
        return tutorialRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Tutorial not found with id " + id));
    }
}