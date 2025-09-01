import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';

import { IonicModule } from '@ionic/angular';

import { ComidasAleatoriasPageRoutingModule } from './comidas-aleatorias-routing.module';

import { ComidasAleatoriasPage } from './comidas-aleatorias.page';

@NgModule({
  imports: [
    CommonModule,
    FormsModule,
    IonicModule,
    ComidasAleatoriasPageRoutingModule
  ],
  declarations: [ComidasAleatoriasPage]
})
export class ComidasAleatoriasPageModule {}
