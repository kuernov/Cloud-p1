import { Component, OnInit } from '@angular/core';
import { Router, ActivatedRoute } from '@angular/router';
import { AuthService } from '../../services/auth.service';

@Component({
  selector: 'app-verify',
  templateUrl: './verify.component.html'
})
export class VerifyComponent implements OnInit {
  email: string = '';
  code: string = '';
  errorMessage: string = '';

  constructor(
    private authService: AuthService,
    private router: Router,
    private route: ActivatedRoute
  ) {}

  ngOnInit() {
    this.route.queryParams.subscribe(params => {
      if (params['email']) {
        this.email = params['email'];
      }
    });
  }

  async verify() {
    try {
      await this.authService.confirmUser(this.email, this.code);
      alert('Account verified! You can now login.');
      this.router.navigate(['/login']); 
    } catch (error: any) {
      console.error('Verification error', error);
      this.errorMessage = error.message || 'Verification failed.';
    }
  }
}