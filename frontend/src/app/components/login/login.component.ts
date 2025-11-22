import { Component } from '@angular/core';
import { Router } from '@angular/router';
import { AuthService } from '../../services/auth.service';

@Component({
  selector: 'app-login',
  templateUrl: './login.component.html'
})
export class LoginComponent {
  email: string = '';
  password: string = '';

  constructor(
    private authService: AuthService,
    private router: Router
  ) {}

  async login() {
    try {
      const tokens = await this.authService.signIn(this.email, this.password);
      console.log('Access Token:', tokens.accessToken);
      
      // Redirect to tutorials list
      this.router.navigate(['/tutorials']);
      
    } catch (error) {
      console.error('Login error', error);
      alert('Login failed. Please check your email and password.');
    }
  }
}