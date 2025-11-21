import { Component } from '@angular/core';
import { Router } from '@angular/router'; // Do przekierowania po sukcesie
import { AuthService } from '../../services/auth.service'; // Twój serwis

@Component({
  selector: 'app-verify',
  templateUrl: './verify.component.html'
})
export class VerifyComponent {
  email: string = '';
  code: string = '';
  errorMessage: string = '';

  constructor(
    private authService: AuthService,
    private router: Router
  ) {}

  async verify() {
    try {
      await this.authService.confirmUser(this.email, this.code);
      alert('Konto potwierdzone! Możesz się zalogować.');
      this.router.navigate(['/login']); // Przekieruj do logowania
    } catch (error: any) {
      console.error('Błąd weryfikacji', error);
      this.errorMessage = error.message || 'Błąd weryfikacji.';
    }
  }
}