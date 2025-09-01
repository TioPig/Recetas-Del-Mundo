import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';

import { SeleccionarPage } from './seleccionar.page';

const routes: Routes = [
  {
    path: '',
    component: SeleccionarPage
  }
];

@NgModule({
  imports: [RouterModule.forChild(routes)],
  exports: [RouterModule],
})
export class SeleccionarPageRoutingModule {}
