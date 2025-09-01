import { ComponentFixture, TestBed } from '@angular/core/testing';
import { PostresPage } from './postres.page';

describe('PostresPage', () => {
  let component: PostresPage;
  let fixture: ComponentFixture<PostresPage>;

  beforeEach(async(() => {
    fixture = TestBed.createComponent(PostresPage);
    component = fixture.componentInstance;
    fixture.detectChanges();
  }));

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
