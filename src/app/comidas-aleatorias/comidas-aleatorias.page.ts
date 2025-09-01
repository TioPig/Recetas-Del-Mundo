import { Component, OnInit } from '@angular/core';
import { MealService2 } from '../services/api.service';

@Component({
  selector: 'app-comidas-aleatorias',
  templateUrl: './comidas-aleatorias.page.html',
  styleUrls: ['./comidas-aleatorias.page.scss'],
})
export class ComidasAleatoriasPage implements OnInit {
  randomMeal: any;

  constructor(private mealService: MealService2) {}

  ngOnInit() {
    this.mealService.getRandomMeal().subscribe(data => {
      console.log(data);
      this.randomMeal = data.meals[0]; // Asumiendo que la API devuelve un objeto con la propiedad "meals"
    });
  }
}
