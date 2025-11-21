import { platformBrowserDynamic } from '@angular/platform-browser-dynamic';
import { AppModule } from './app/app.module';
import { Amplify } from 'aws-amplify';
import { environment } from './environments/environment'; // <-- Tu jest klucz!

// 1. Konfiguracja Amplify
// Angular pobiera te wartości z environment.ts, 
// a environment.ts pobiera je z window.env (z pliku config.js)
Amplify.configure({
  Auth: {
    Cognito: {
      userPoolId: environment.cognito_user_pool_id,
      userPoolClientId: environment.cognito_app_client_id,
      loginWith: {
        email: true,
      }
    }
  }
});

// 2. Start aplikacji
platformBrowserDynamic().bootstrapModule(AppModule)
  .catch(err => console.error(err));