import { inject } from '@angular/core';
import { CanActivateFn, Router } from '@angular/router';
import Auth from '@aws-amplify/auth';

export const authGuard: CanActivateFn = async () => {
  const router = inject(Router);

  try {
    await Auth.getCurrentUser(); // zamiast currentAuthenticatedUser()
    return true; // użytkownik zalogowany, pozwól wejść
  } catch {
    router.navigate(['/login']); // przekieruj na login jeśli nie
    return false;
  }
};
