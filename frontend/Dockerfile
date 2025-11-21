# ----------------------------
# Etap 1: Budowanie aplikacji (Build Stage)
# ----------------------------
FROM node:20 AS build
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
# Budowanie aplikacji w trybie produkcyjnym
RUN npm run build -- --configuration production

# ----------------------------
# Etap 2: Serwowanie przez Nginx (Production Stage)
# ----------------------------
FROM nginx:alpine

# Ustawiamy katalog roboczy Nginxa
WORKDIR /usr/share/nginx/html

# 1. Kopiowanie zbudowanej aplikacji z etapu 'build'
# Upewnij się, że ścieżka '/app/dist/angular-17-crud/browser/' zgadza się z nazwą Twojego projektu w angular.json
COPY --from=build /app/dist/angular-17-crud/browser/ ./

# 2. Kopiowanie konfiguracji Nginxa (jeśli masz własny plik, jeśli nie - usuń tę linię)
COPY nginx.conf /etc/nginx/conf.d/default.conf

# 3. Kopiowanie skryptu startowego (entrypoint.sh)
# Zakładamy, że plik jest w tym samym folderze co Dockerfile
COPY entrypoint.sh /docker-entrypoint.sh

# 4. Nadawanie uprawnień do wykonywania (krytyczne!)
RUN chmod +x /docker-entrypoint.sh

# 5. Wystawienie portu 80
EXPOSE 80

# 6. Ustawienie Entrypointu
# To sprawia, że przy starcie kontenera NAJPIERW uruchomi się nasz skrypt,
# wygeneruje config.js, a dopiero potem uruchomi Nginxa.
ENTRYPOINT ["/docker-entrypoint.sh"]

# 7. Domyślna komenda (przekazywana do exec "$@" w skrypcie)
CMD ["nginx", "-g", "daemon off;"]