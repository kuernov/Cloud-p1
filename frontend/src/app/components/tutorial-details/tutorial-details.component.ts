import { Component, Input, OnInit } from '@angular/core';
import { ActivatedRoute, Router } from '@angular/router';
import { Tutorial } from '../../models/tutorial.model';
import { TutorialService } from '../../services/tutorial.service';
import { FileService } from '../../services/file.service';
import { AppComment } from '../../models/comment.model';

@Component({
  selector: 'app-tutorial-details',
  templateUrl: './tutorial-details.component.html',
  styleUrls: ['./tutorial-details.component.css'],
})
export class TutorialDetailsComponent implements OnInit {
  @Input() viewMode = false;

  @Input() currentTutorial: Tutorial = {
    id: 0,
    title: '',
    description: '',
    published: false,
    imagePath: ''
  };

  comments: AppComment[] = [];
  newComment: AppComment = { author: '', text: '' };
  message = '';
  selectedFile?: File;

  constructor(
    private tutorialService: TutorialService,
    private fileService: FileService,
    private route: ActivatedRoute,
    private router: Router
  ) {}

  ngOnInit(): void {
    if (!this.viewMode) {
      const id = this.route.snapshot.params['id'];
      if (id) {
        this.getTutorial(id);
      }
    }
  }

  // Pobranie tutoriala i komentarzy
  getTutorial(id: string | number): void {
    this.tutorialService.get(id).subscribe({
      next: (data) => {
        this.currentTutorial = data;
        this.getComments(data.id);
      },
      error: (e) => console.error(e)
    });
  }

  updatePublished(status: boolean): void {
    const data = {
      title: this.currentTutorial.title,
      description: this.currentTutorial.description,
      published: status
    };
    this.tutorialService.update(this.currentTutorial.id, data).subscribe({
      next: () => {
        this.currentTutorial.published = status;
        this.message = 'The status was updated successfully!';
      },
      error: (e) => console.error(e)
    });
  }

  updateTutorial(): void {
    this.tutorialService.update(this.currentTutorial.id, this.currentTutorial).subscribe({
      next: () => this.message = 'This tutorial was updated successfully!',
      error: (e) => console.error(e)
    });
  }

  deleteTutorial(): void {
    this.tutorialService.delete(this.currentTutorial.id).subscribe({
      next: () => this.router.navigate(['/tutorials']),
      error: (e) => console.error(e)
    });
  }

  // ------------------- Comments -------------------

  getComments(tutorialId: string | number): void {
    this.tutorialService.getComments(tutorialId).subscribe({
      next: (data: AppComment[]) => this.comments = data,
      error: (e) => console.error(e)
    });
  }

  addComment(): void {
    if (!this.newComment.author || !this.newComment.text) return;
    this.tutorialService.addComment(this.currentTutorial.id, this.newComment).subscribe({
      next: (comment: AppComment) => {
        this.comments.push(comment);
        this.newComment = { author: '', text: '' };
      },
      error: (e) => console.error(e)
    });
  }

  // ------------------- File upload -------------------

  onFileSelected(event: any): void {
    this.selectedFile = event.target.files[0];
  }

  uploadFile(): void {
    if (!this.selectedFile) return;

    this.fileService.upload(this.selectedFile).subscribe({
      next: (filename: string) => {
        this.currentTutorial.imagePath = filename;
        console.log('File uploaded:', filename);
      },
      error: (e) => console.error(e)
    });
  }

  // Pobranie URL obrazka
  getImageUrl(): string {
    return this.currentTutorial.imagePath
      // ZMIEŃ TĘ LINIĘ: Usuń "http://localhost:8080"
      ? `/api/files/${this.currentTutorial.imagePath}`
      : '';
  }
}
