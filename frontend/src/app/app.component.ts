import { Component, OnInit } from '@angular/core';
import { Router, NavigationEnd } from '@angular/router'; // Dodaj NavigationEnd
import { AuthService } from './services/auth.service';
import { Hub } from 'aws-amplify/utils'; 
import { filter } from 'rxjs/operators'; // Dodaj filter

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css']
})
export class AppComponent implements OnInit {
  title = 'Angular17Crud';
  isLoggedIn = false;
  showNavbar = true; // Nowa flaga sterująca widocznością całego paska

  constructor(
    private authService: AuthService,
    private router: Router
  ) {}

  async ngOnInit() {
    this.checkLoginStatus();

    // 1. Nasłuchuj zmian w URL, aby ukrywać navbar na stronach logowania
    this.router.events.pipe(
      filter(event => event instanceof NavigationEnd)
    ).subscribe((event: any) => {
      // Lista ścieżek, gdzie navbar ma być ukryty
      const hiddenRoutes = ['/login', '/register', '/verify'];
      
      // Sprawdzamy czy obecny URL zawiera którąś z tych ścieżek
      // Używamy includes, żeby obsłużyć też parametry np. /verify?email=...
      const isHidden = hiddenRoutes.some(route => event.urlAfterRedirects.includes(route));
      
      this.showNavbar = !isHidden;
    });

    // 2. Nasłuchuj na zdarzenia Amplify (Auth)
    Hub.listen('auth', ({ payload }) => {
      switch (payload.event) {
        case 'signedIn':
          this.isLoggedIn = true;
          break;
        case 'signedOut':
          this.isLoggedIn = false;
          this.router.navigate(['/login']);
          break;
      }
    });
  }

  async checkLoginStatus() {
    try {
      await this.authService.getCurrentUser();
      this.isLoggedIn = true;
    } catch (error) {
      this.isLoggedIn = false;
    }
  }

  async logout() {
    try {
      await this.authService.signOut();
    } catch (error) {
      console.error('Logout error', error);
    }
  }
}