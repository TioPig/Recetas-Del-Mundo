import { Component, OnInit } from '@angular/core';
import { UsuarioService } from '../services/api.service';

@Component({
  selector: 'app-login',
  templateUrl: './login.page.html',
  styleUrls: ['./login.page.scss'],
})
export class LoginPage implements OnInit {

  usuario: any[0];

  constructor(private categoriaService: UsuarioService) { }

  ngOnInit() {
    this.categoriaService.getCategorias().subscribe(data => {
      console.log(data)
      this.usuario = data;
    });
  }

}