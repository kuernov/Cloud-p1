import { Injectable } from '@angular/core';
import { HttpClient, HttpEvent, HttpRequest } from '@angular/common/http';
import { Observable } from 'rxjs';

const fileUrl = '/api/files';

@Injectable({
  providedIn: 'root',
})
export class FileService {
  constructor(private http: HttpClient) {}

  upload(file: File): Observable<string> {
    const formData: FormData = new FormData();
    formData.append('file', file);

    // Dodaj responseType: 'text'
    return this.http.post(`${fileUrl}/upload`, formData, { responseType: 'text' });
  }

  download(filename: string): Observable<Blob> {
    return this.http.get(`${fileUrl}/${filename}`, { responseType: 'blob' });
  }
}
