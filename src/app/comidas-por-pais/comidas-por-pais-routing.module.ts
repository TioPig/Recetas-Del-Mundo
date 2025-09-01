import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';

import { ComidasPorPaisPage } from './comidas-por-pais.page';

const routes: Routes = [
  {
    path: '',
    component: ComidasPorPaisPage
  }
];

@NgModule({
  imports: [RouterModule.forChild(routes)],
  exports: [RouterModule],
})
export class ComidasPorPaisPageRoutingModule {}
