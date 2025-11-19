import { platformBrowserDynamic } from '@angular/platform-browser-dynamic';
import Auth from '@aws-amplify/auth';
import { environment } from './environment';
import { AppModule } from './app/app.module';

Auth.configure({
    region: environment.cognito_region,
    userPoolId: environment.cognito_user_pool_id,
    userPoolWebClientId: environment.cognito_app_client_id,
    mandatorySignIn: true,
});

platformBrowserDynamic().bootstrapModule(AppModule)
  .catch(err => console.error(err));
