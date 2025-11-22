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
      
      alert('Registration successful! Please check your email for the verification code.');
      
      // Redirect to verify page with email parameter
      this.router.navigate(['/verify'], { 
        queryParams: { email: this.email } 
      });
      
    } catch (error) {
      console.error('Registration error', error);
      alert('Registration failed. Please try again.');
    }
  }
}