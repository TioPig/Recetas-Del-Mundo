import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';

import { ComidasAleatoriasPage } from './comidas-aleatorias.page';

const routes: Routes = [
  {
    path: '',
    component: ComidasAleatoriasPage
  }
];

@NgModule({
  imports: [RouterModule.forChild(routes)],
  exports: [RouterModule],
})
export class ComidasAleatoriasPageRoutingModule {}
