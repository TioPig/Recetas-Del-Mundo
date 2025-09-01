import { ComponentFixture, TestBed } from '@angular/core/testing';
import { ComidasPorPaisPage } from './comidas-por-pais.page';

describe('ComidasPorPaisPage', () => {
  let component: ComidasPorPaisPage;
  let fixture: ComponentFixture<ComidasPorPaisPage>;

  beforeEach(async(() => {
    fixture = TestBed.createComponent(ComidasPorPaisPage);
    component = fixture.componentInstance;
    fixture.detectChanges();
  }));

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
