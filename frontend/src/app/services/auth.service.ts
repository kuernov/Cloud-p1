import { Injectable } from '@angular/core';
import {
  signUp,
  signIn,
  signOut,
  fetchAuthSession,
  confirmSignUp,
  getCurrentUser
} from 'aws-amplify/auth';

@Injectable({
  providedIn: 'root'
})
export class AuthService {

  async signUp(email: string, password: string) {
    return await signUp({
      username: email,
      password,
      // ▼▼▼ KLUCZOWA POPRAWKA ▼▼▼
      // Musisz przekazać email w userAttributes, bo Cognito tego wymaga
      options: {
        userAttributes: {
          email: email
        },
        // Opcjonalnie: automatyczne logowanie po potwierdzeniu maila
        autoSignIn: true
      }
      // ▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲
    });
  }

    async confirmUser(email: string, code: string) {
    return await confirmSignUp({
      username: email,
      confirmationCode: code
    });
  }

  async signIn(email: string, password: string) {
    const result = await signIn({ username: email, password });

    // Pobieramy sesję, aby uzyskać tokeny (JWT)
    const session = await fetchAuthSession();

    return {
      result,
      idToken: session.tokens?.idToken,
      accessToken: session.tokens?.accessToken,
    };
  }

  async signOut() {
    return await signOut();
  }

  async getCurrentUser() {
    return await getCurrentUser();
  }
}