import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';

// Base URL centralizada (cambio mínimo para facilitar ajustes sin refactor)
const API_BASE = 'http://localhost:8081';

// APIS LOCALES FUNCIONALES

// módulo para obtener datos de categorías
@Injectable({
  providedIn: 'root'
})
export class MealService {
  private apiUrl = API_BASE + '/api/categorias';

  constructor(private http: HttpClient) { }

  getCategories(): Observable<any> {
    return this.http.get(this.apiUrl);
  }
}

// módulo para obtener información de la api randoms
@Injectable({
  providedIn: 'root'
})
export class MealService2 {
  private apiUrl = API_BASE + '/api/recetas';

  constructor(private http: HttpClient) {}

  getRandomMeal(): Observable<any> {
    return this.http.get(this.apiUrl);
  }
}

// Módulo para los paises

@Injectable({
  providedIn: 'root'
})
export class MealService3 {
  private apiUrl = API_BASE + '/api/paises';

  constructor(private http: HttpClient) { }

  getPaises(): Observable<any> {
    return this.http.get(this.apiUrl);
  }
}

/////// SERVICIOS PARA OBTENER DATOS DE UNA BBDD MYSQL MEDIANTE SPRINGBOOT ///////

// desde el localhost para las comidas por tipo (categorías) (springboot)
@Injectable({
  providedIn: 'root'
})
export class CategoriaService {

  private apiUrl = API_BASE + '/api/categorias';

  constructor(private http: HttpClient) { }

  getCategorias() {
    return this.http.get<any[]>(this.apiUrl);
  }
}

// desde el localhost para obtener los datos de cada país
@Injectable({
  providedIn: 'root'
})
export class FlagService {

  private apiUrl = API_BASE + '/api/paises';

  constructor(private http: HttpClient) { }

  getCategorias() {
    return this.http.get<any[]>(this.apiUrl);
  }
}

// Servicio frontend para recetas (consume los endpoints del backend)
@Injectable({
  providedIn: 'root'
})
export class RecetaFrontendService {

  private apiUrl = API_BASE + '/api/recetas';

  constructor(private http: HttpClient) { }

  // Obtener todas las recetas
  getRecetas() {
    return this.http.get<any[]>(this.apiUrl);
  }

  // Obtener recetas por id de país
  getRecetasPorPais(id_pais: number) {
    return this.http.get<any[]>(`${this.apiUrl}/pais/${id_pais}`);
  }

  // Búsqueda parcial por nombre (case-insensitive)
  buscarRecetasPorNombreParcial(nombre: string) {
    return this.http.get<any[]>(`${this.apiUrl}/buscar/nombre/${encodeURIComponent(nombre)}`);
  }

}

// desde el localhost para obtener los datos de los postres
@Injectable({
  providedIn: 'root'
})
export class PostreService {

  private apiUrl = API_BASE + '/api/recetas';

  constructor(private http: HttpClient) { }

  getCategorias() {
    return this.http.get<any[]>(this.apiUrl);
  }
}

// para desplegar usuarios destacados jaja
@Injectable({
  providedIn: 'root'
})
export class UsuarioService {

  private apiUrl = API_BASE + '/api/usuarios';

  constructor(private http: HttpClient) { }

  getCategorias() {
    return this.http.get<any[]>(this.apiUrl);
  }
}