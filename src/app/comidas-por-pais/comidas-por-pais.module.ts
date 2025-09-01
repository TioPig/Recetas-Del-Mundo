import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';

import { IonicModule } from '@ionic/angular';
import { HttpClientModule } from '@angular/common/http';
import { ComidasPorPaisPageRoutingModule } from './comidas-por-pais-routing.module';

import { ComidasPorPaisPage } from './comidas-por-pais.page';

@NgModule({
  imports: [
    CommonModule,
    FormsModule,
    IonicModule,
    ComidasPorPaisPageRoutingModule,
    HttpClientModule
  ],
  declarations: [ComidasPorPaisPage]
})
export class ComidasPorPaisPageModule {}
