import { Component, OnInit } from '@angular/core';
import { MealService,CategoriaService } from '../services/api.service';

@Component({
  selector: 'app-comidas-por-tipo',
  templateUrl: './comidas-por-tipo.page.html',
  styleUrls: ['./comidas-por-tipo.page.scss'],
})
// export class ComidasPorTipoPage implements OnInit {
//   categories: any;

//   constructor(private mealService: MealService) {}

//   ngOnInit() {
//     this.mealService.getCategories().subscribe((data) => {
//       console.log(data)
//       this.categories = data.categories;
      
//     });
//   }
// }



////////////////////////


export class ComidasPorTipoPage implements OnInit {

  categories: any[0];

  constructor(private categoriaService: CategoriaService) { }

  ngOnInit() {
    this.categoriaService.getCategorias().subscribe(data => {
      console.log(data)
      this.categories = data;
    });
  }

}
