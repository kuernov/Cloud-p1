#!/bin/sh

# Upewniamy się, że katalog assets istnieje (w oficjalnym obrazie nginx może go nie być)
mkdir -p /tmp/assets

# Tworzymy plik config.js, wypełniając go wartościami ze zmiennych środowiskowych (ENV).
# Zmienne te (COGNITO_REGION itp.) są dostarczane przez AWS ECS (zdefiniowane w Terraformie).
cat <<EOF > /tmp/assets/config.js
window.env = {
  cognito_region: "${COGNITO_REGION}",
  cognito_user_pool_id: "${COGNITO_USER_POOL_ID}",
  cognito_app_client_id: "${COGNITO_APP_CLIENT_ID}"
};
EOF

# Wykonujemy domyślną komendę przekazaną do kontenera (czyli start Nginxa)
# "exec" jest ważne, aby Nginx przejął PID 1 i odbierał sygnały systemowe (np. SIGTERM przy zatrzymywaniu)
exec "$@"