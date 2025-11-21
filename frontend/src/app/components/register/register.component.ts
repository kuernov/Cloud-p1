import { Component } from '@angular/core';
import { Router } from '@angular/router'; 
import { AuthService } from '../../services/auth.service';

@Component({
  selector: 'app-register',
  templateUrl: './register.component.html'
})
export class RegisterComponent {
  email: string = '';
  password: string = '';

  constructor(
    private authService: AuthService,
    private router: Router 
  ) {}

  async register() {
    try {
      await this.authService.signUp(this.email, this.password);
      
      // alert('Rejestracja udana! Sprawdź kod w mailu.'); // Opcjonalnie usuń alert, żeby było płynniej
      
      // ▼▼▼ PRZEKIEROWANIE Z PARAMETREM ▼▼▼
      // Przenosimy użytkownika na /verify i doklejamy ?email=...
      this.router.navigate(['/verify'], { 
        queryParams: { email: this.email } 
      });
      
    } catch (error) {
      console.error('Błąd rejestracji', error);
      alert('Nie udało się zarejestrować');
    }
  }
}