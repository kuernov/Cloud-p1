import { Injectable } from '@angular/core';
import Auth from '@aws-amplify/auth';

@Injectable({
  providedIn: 'root'
})
export class AuthService {

  async signUp(email: string, password: string) {
    return await Auth.signUp({ username: email, password });
  }

  async signIn(email: string, password: string) {
    const user = await Auth.signIn({ username: email, password }); // obiekt zamiast dwóch argumentów
    const session = await Auth.getSession(); // zamiast currentSession()
    return {
      idToken: session.getIdToken().getJwtToken(),
      accessToken: session.getAccessToken().getJwtToken(),
      refreshToken: session.getRefreshToken().getToken()
    };
  }

  async signOut() {
    return await Auth.signOut();
  }

  async getCurrentUser() {
    return await Auth.getCurrentUser(); // zamiast currentAuthenticatedUser()
  }
}
