import { Injectable } from '@angular/core';
import { HttpInterceptor, HttpRequest, HttpHandler, HttpEvent } from '@angular/common/http';
import { Observable, from, of } from 'rxjs';
import { switchMap, catchError } from 'rxjs/operators';
import Auth from '@aws-amplify/auth';

@Injectable()
export class JwtInterceptor implements HttpInterceptor {
  intercept(req: HttpRequest<any>, next: HttpHandler): Observable<HttpEvent<any>> {
    return from(Auth.getSession()).pipe(
      switchMap(session => {
        const token = session.getAccessToken().getJwtToken();
        const authReq = req.clone({
          setHeaders: { Authorization: `Bearer ${token}` }
        });
        return next.handle(authReq);
      }),
      catchError(() => {
        // Jeśli brak sesji, po prostu prześlij request bez tokenu
        return next.handle(req);
      })
    );
  }
}
