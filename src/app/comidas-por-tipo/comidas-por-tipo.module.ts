import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';

import { IonicModule } from '@ionic/angular';

import { ComidasPorTipoPageRoutingModule } from './comidas-por-tipo-routing.module';
import { HttpClientModule } from '@angular/common/http';
import { ComidasPorTipoPage } from './comidas-por-tipo.page';

@NgModule({
  imports: [
    CommonModule,
    FormsModule,
    IonicModule,
    ComidasPorTipoPageRoutingModule,
    HttpClientModule
  ],
  declarations: [ComidasPorTipoPage]
})
export class ComidasPorTipoPageModule {}
