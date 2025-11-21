export const environment = {
  production: true,

  
  cognito_region: (window as any).env?.cognito_region,
  
  cognito_user_pool_id: (window as any).env?.cognito_user_pool_id,
  
  cognito_app_client_id: (window as any).env?.cognito_app_client_id
};