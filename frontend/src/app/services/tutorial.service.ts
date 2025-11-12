import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { Tutorial } from '../models/tutorial.model';
import { AppComment } from '../models/comment.model';

const baseUrl = '/api/tutorials';

@Injectable({
  providedIn: 'root',
})
export class TutorialService {
  constructor(private http: HttpClient) {}

  getAll(): Observable<Tutorial[]> {
    return this.http.get<Tutorial[]>(baseUrl);
  }

  get(id: any): Observable<Tutorial> {
    return this.http.get<Tutorial>(`${baseUrl}/${id}`);
  }

  create(data: any): Observable<Tutorial> {
    // data: { title, description, imagePath }
    return this.http.post<Tutorial>(baseUrl, data);
  }

  update(id: any, data: any): Observable<Tutorial> {
    return this.http.put<Tutorial>(`${baseUrl}/${id}`, data);
  }

  delete(id: any): Observable<any> {
    return this.http.delete(`${baseUrl}/${id}`);
  }

  deleteAll(): Observable<any> {
    return this.http.delete(baseUrl);
  }

  findByTitle(title: any): Observable<Tutorial[]> {
    return this.http.get<Tutorial[]>(`${baseUrl}?title=${title}`);
  }

  getComments(tutorialId: number | string): Observable<AppComment[]> {
    return this.http.get<AppComment[]>(`${baseUrl}/${tutorialId}/comments`);
  }

  addComment(tutorialId: number | string, comment: AppComment): Observable<AppComment> {
    return this.http.post<AppComment>(`${baseUrl}/${tutorialId}/comments`, comment);
  }
}
