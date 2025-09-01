import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';

import { IonicModule } from '@ionic/angular';

import { SeleccionarPageRoutingModule } from './seleccionar-routing.module';

import { SeleccionarPage } from './seleccionar.page';

@NgModule({
  imports: [
    CommonModule,
    FormsModule,
    IonicModule,
    SeleccionarPageRoutingModule
  ],
  declarations: [SeleccionarPage]
})
export class SeleccionarPageModule {}
