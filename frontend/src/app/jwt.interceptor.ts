import { Injectable } from '@angular/core';
import { HttpInterceptor, HttpRequest, HttpHandler } from '@angular/common/http';
import { Observable, from } from 'rxjs';
import { switchMap } from 'rxjs/operators';
import { fetchAuthSession } from 'aws-amplify/auth';

@Injectable()
export class JwtInterceptor implements HttpInterceptor {
  intercept(req: HttpRequest<any>, next: HttpHandler): Observable<any> {
    return from(fetchAuthSession()).pipe(
      switchMap(session => {
        const token = session.tokens?.accessToken;
        const cloned = req.clone({
          setHeaders: token ? { Authorization: `Bearer ${token}` } : {}
        });
        return next.handle(cloned);
      })
    );
  }
}
