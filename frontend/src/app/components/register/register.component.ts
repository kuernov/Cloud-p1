import { Component } from '@angular/core';
import { AuthService } from '../../services/auth.service';

@Component({
  selector: 'app-register',
  templateUrl: './register.component.html'
})
export class RegisterComponent {
  email: string = '';
  password: string = '';

  constructor(private authService: AuthService) {}

  async register() {
    try {
      await this.authService.signUp(this.email, this.password);
      alert('Rejestracja zakończona! Sprawdź email w celu weryfikacji.');
    } catch (error) {
      console.error('Błąd rejestracji', error);
      alert('Nie udało się zarejestrować');
    }
  }
}
