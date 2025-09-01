import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';

import { ComidasPorTipoPage } from './comidas-por-tipo.page';

const routes: Routes = [
  {
    path: '',
    component: ComidasPorTipoPage
  }
];

@NgModule({
  imports: [RouterModule.forChild(routes)],
  exports: [RouterModule],
})
export class ComidasPorTipoPageRoutingModule {}
