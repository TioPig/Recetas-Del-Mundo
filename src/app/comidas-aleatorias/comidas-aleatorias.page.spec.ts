import { ComponentFixture, TestBed } from '@angular/core/testing';
import { ComidasAleatoriasPage } from './comidas-aleatorias.page';

describe('ComidasAleatoriasPage', () => {
  let component: ComidasAleatoriasPage;
  let fixture: ComponentFixture<ComidasAleatoriasPage>;

  beforeEach(async(() => {
    fixture = TestBed.createComponent(ComidasAleatoriasPage);
    component = fixture.componentInstance;
    fixture.detectChanges();
  }));

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
