package com.bezkoder.spring.jpa.postgresql.controller;

// Usunięto nieużywane importy (IOException, Path, Resource, UrlResource, FileStorageService, itp.)
import java.util.List;

import com.bezkoder.spring.jpa.postgresql.model.Comment;
import com.bezkoder.spring.jpa.postgresql.repository.CommentRepository;
import com.bezkoder.spring.jpa.postgresql.service.TutorialService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.bezkoder.spring.jpa.postgresql.model.Tutorial;


@CrossOrigin(origins = "http://localhost:8081")
@RestController
@RequestMapping("/api/tutorials")
public class TutorialController {

    @Autowired
    private TutorialService tutorialService;

    @Autowired
    private CommentRepository commentRepository;

    // ------------------- CRUD Tutorial -------------------

    @GetMapping
    public ResponseEntity<List<Tutorial>> getAllTutorials(@RequestParam(required = false) String title) {
        List<Tutorial> tutorials = tutorialService.getAllTutorials(title);
        return tutorials.isEmpty() ? ResponseEntity.noContent().build() : ResponseEntity.ok(tutorials);
    }

    @GetMapping("/published")
    public ResponseEntity<List<Tutorial>> getPublishedTutorials() {
        List<Tutorial> tutorials = tutorialService.getPublishedTutorials();
        return tutorials.isEmpty() ? ResponseEntity.noContent().build() : ResponseEntity.ok(tutorials);
    }

    @GetMapping("/{id}")
    public ResponseEntity<Tutorial> getTutorialById(@PathVariable long id) {
        Tutorial tutorial = tutorialService.getTutorialById(id);
        return ResponseEntity.ok(tutorial);
    }

    @PostMapping
    public ResponseEntity<Tutorial> createTutorial(@RequestBody Tutorial tutorial) {
        Tutorial created = tutorialService.createTutorial(
                tutorial.getTitle(),
                tutorial.getDescription(),
                tutorial.getImagePath() // przekazujemy nazwę wcześniej wgranego pliku
        );
        return ResponseEntity.ok(created);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Tutorial> updateTutorial(@PathVariable long id, @RequestBody Tutorial tutorial) {
        Tutorial updated = tutorialService.updateTutorial(id, tutorial);
        return ResponseEntity.ok(updated);
    }

    // --- POPRAWKA TUTAJ ---
    // Usunięto 'throws IOException' z sygnatury metody
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteTutorial(@PathVariable long id) {
        tutorialService.deleteTutorial(id);
        return ResponseEntity.noContent().build();
    }

    // --- POPRAWKA TUTAJ ---
    // Usunięto 'throws IOException' z sygnatury metody
    @DeleteMapping
    public ResponseEntity<Void> deleteAllTutorials() {
        tutorialService.deleteAllTutorials();
        return ResponseEntity.noContent().build();
    }

    // ------------------- Comments -------------------

    @PostMapping("/{id}/comments")
    public ResponseEntity<Comment> addComment(@PathVariable Long id, @RequestBody Comment comment) {
        Tutorial tutorial = tutorialService.getTutorialById(id);
        comment.setTutorial(tutorial);
        Comment saved = commentRepository.save(comment);
        return ResponseEntity.ok(saved);
    }

    @GetMapping("/{id}/comments")
    public ResponseEntity<List<Comment>> getComments(@PathVariable Long id) {
        Tutorial tutorial = tutorialService.getTutorialById(id);
        List<Comment> comments = commentRepository.findByTutorialId(tutorial.getId());
        return comments.isEmpty() ? ResponseEntity.noContent().build() : ResponseEntity.ok(comments);
    }
}