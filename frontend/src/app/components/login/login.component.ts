import { Component } from '@angular/core';
import { AuthService } from '../../services/auth.service';

@Component({
  selector: 'app-login',
  templateUrl: './login.component.html'
})
export class LoginComponent {
  email: string = '';
  password: string = '';

  constructor(private authService: AuthService) {}

  async login() {
    try {
      const tokens = await this.authService.signIn(this.email, this.password);
      console.log('Access Token:', tokens.accessToken);
      console.log('ID Token:', tokens.idToken);
      alert('Zalogowano pomyślnie!');
    } catch (error) {
      console.error('Błąd logowania', error);
      alert('Nie udało się zalogować');
    }
  }
}
