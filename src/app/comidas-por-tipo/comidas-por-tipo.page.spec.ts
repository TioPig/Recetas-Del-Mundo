import { ComponentFixture, TestBed } from '@angular/core/testing';
import { ComidasPorTipoPage } from './comidas-por-tipo.page';

describe('ComidasPorTipoPage', () => {
  let component: ComidasPorTipoPage;
  let fixture: ComponentFixture<ComidasPorTipoPage>;

  beforeEach(async(() => {
    fixture = TestBed.createComponent(ComidasPorTipoPage);
    component = fixture.componentInstance;
    fixture.detectChanges();
  }));

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
