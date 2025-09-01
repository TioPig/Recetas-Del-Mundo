import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';

import { PostresPage } from './postres.page';

const routes: Routes = [
  {
    path: '',
    component: PostresPage
  }
];

@NgModule({
  imports: [RouterModule.forChild(routes)],
  exports: [RouterModule],
})
export class PostresPageRoutingModule {}
