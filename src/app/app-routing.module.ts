import { NgModule } from '@angular/core';
import { PreloadAllModules, RouterModule, Routes } from '@angular/router';
import { AuthGuard } from '../app/guards/auth.guard';

const routes: Routes = [
  {
    path: 'home',
    loadChildren: () => import('./home/home.module').then( m => m.HomePageModule)
  },

  {
    path: '',
    redirectTo: 'home',
    pathMatch: 'full'
  },
 


  {
    path: 'login',
    loadChildren: () => import('./login/login.module').then( m => m.LoginPageModule)
  },
  {
    path: 'postres',
    loadChildren: () => import('./postres/postres.module').then( m => m.PostresPageModule)
  },
  // protegida con guards
  {
    path: 'seleccionar',
    loadChildren: () => import('./seleccionar/seleccionar.module').then( m => m.SeleccionarPageModule),
    canActivate: [AuthGuard]
  },
  {
    path: 'comidas-por-pais',
    loadChildren: () => import('./comidas-por-pais/comidas-por-pais.module').then( m => m.ComidasPorPaisPageModule)
  },
  {
    path: 'comidas-por-tipo',
    loadChildren: () => import('./comidas-por-tipo/comidas-por-tipo.module').then( m => m.ComidasPorTipoPageModule)
  },
  {
    path: 'comidas-aleatorias',
    loadChildren: () => import('./comidas-aleatorias/comidas-aleatorias.module').then( m => m.ComidasAleatoriasPageModule)
  },
  // esto redirige a las pags que no estén autenticadas con el guard
  { path: '**', redirectTo: 'home' }
];

@NgModule({
  imports: [
    RouterModule.forRoot(routes, { preloadingStrategy: PreloadAllModules })
  ],
  exports: [RouterModule]
})
export class AppRoutingModule { }

