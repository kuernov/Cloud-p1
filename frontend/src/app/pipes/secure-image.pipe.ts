import { Pipe, PipeTransform } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { DomSanitizer, SafeUrl } from '@angular/platform-browser';
import { Observable, from, of } from 'rxjs';
import { map, switchMap, catchError } from 'rxjs/operators';
import { fetchAuthSession } from 'aws-amplify/auth';


@Pipe({
  name: 'secureImage'
})
export class SecureImagePipe implements PipeTransform {

  constructor(private http: HttpClient, private sanitizer: DomSanitizer) {}

  transform(url: string): Observable<SafeUrl> {
    if (!url) {
      return of('assets/placeholder.png'); // Podmień na ścieżkę do swojego placeholdera
    }

    // 1. Pobierz sesję z Amplify (Promise -> Observable)
    return from(fetchAuthSession()).pipe(
      switchMap(session => {
        // 2. Wyciągnij Token
        const token = session.tokens?.idToken?.toString();
        
        // 3. Przygotuj nagłówki
        let headers = new HttpHeaders();
        if (token) {
          headers = headers.set('Authorization', `Bearer ${token}`);
        }

        // 4. Pobierz obrazek jako BLOB (plik binarny)
        return this.http.get(url, { headers, responseType: 'blob' });
      }),
      map(blob => {
        // 5. Stwórz URL z Bloba
        const objectUrl = URL.createObjectURL(blob);
        // 6. Powiedz Angularowi, że ten URL jest bezpieczny
        return this.sanitizer.bypassSecurityTrustUrl(objectUrl);
      }),
      catchError(err => {
        console.error('Błąd ładowania obrazka:', err);
        return of('assets/error-image.png'); // Obrazek błędu
      })
    );
  }
}