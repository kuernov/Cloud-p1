import { Component } from '@angular/core';
import { Tutorial } from '../../models/tutorial.model';
import { TutorialService } from '../../services/tutorial.service';
import { FileService } from '../../services/file.service';

@Component({
  selector: 'app-add-tutorial',
  templateUrl: './add-tutorial.component.html',
  styleUrls: ['./add-tutorial.component.css'],
})
export class AddTutorialComponent {
  tutorial: Tutorial = {
    title: '',
    description: '',
    published: false,
    imagePath: ''
  };
  submitted = false;
  selectedFile: File | null = null;

  constructor(
    private tutorialService: TutorialService,
    private fileService: FileService
  ) {}

  onFileSelected(event: any): void {
    this.selectedFile = event.target.files[0];
  }

  uploadFileAndCreateTutorial(): void {
    if (!this.selectedFile) {
      console.error('Nie wybrano pliku!');
      return;
    }

    // 1️⃣ Upload pliku
    this.fileService.upload(this.selectedFile).subscribe({
      next: (filename: string) => {
        console.log('Plik wgrany:', filename);

        // 2️⃣ Tworzenie tutoriala z nazwą wgranego pliku
        this.tutorial.imagePath = filename;
        this.tutorialService.create(this.tutorial).subscribe({
          next: (res) => {
            console.log('Tutorial utworzony:', res);
            this.submitted = true;
          },
          error: (e) => console.error('Błąd tworzenia tutoriala:', e)
        });
      },
      error: (e) => console.error('Błąd uploadu pliku:', e)
    });
  }

  newTutorial(): void {
    this.submitted = false;
    this.tutorial = {
      title: '',
      description: '',
      published: false,
      imagePath: ''
    };
    this.selectedFile = null;
  }
}
