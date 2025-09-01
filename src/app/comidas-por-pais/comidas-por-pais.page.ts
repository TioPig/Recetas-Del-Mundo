import { Component, OnInit } from '@angular/core';
import { FlagService, RecetaFrontendService } from '../services/api.service';

@Component({
  selector: 'app-comidas-por-pais',
  templateUrl: './comidas-por-pais.page.html',
  styleUrls: ['./comidas-por-pais.page.scss'],
})

// export class ComidasPorPaisPage implements OnInit {
//   pais: any;

//   constructor(private mealService: MealService3) {}

//   ngOnInit() {
//     this.mealService.getPaises().subscribe((data) => {
//       console.log(data)
//       this.pais = data.pais;
      
//     });
//   }
// }


export class ComidasPorPaisPage implements OnInit {

  pais: any[] = [];
  recetas: any[] = [];
  seleccionadoIdPais: number | null = null;

  constructor(private categoriaService: FlagService, private recetaService: RecetaFrontendService) { }

  ngOnInit() {
    this.categoriaService.getCategorias().subscribe(data => {
      console.log('paises', data)
      this.pais = data;
    });
  }

  seleccionarPais(id_pais: number) {
    this.seleccionadoIdPais = id_pais;
    this.recetaService.getRecetasPorPais(id_pais).subscribe(data => {
      console.log('recetas por pais', data);
      this.recetas = data;
    }, err => {
      console.error('error al obtener recetas por pais', err);
      this.recetas = [];
    });
  }

}