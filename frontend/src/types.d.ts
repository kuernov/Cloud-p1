// Ten plik definiuje globalne typy dla całej aplikacji
export {}; // To sprawia, że plik jest traktowany jako moduł definicji

declare global {
  interface Window {
    env: {
      cognito_region: string;
      cognito_user_pool_id: string;
      cognito_app_client_id: string;
    };
  }
}