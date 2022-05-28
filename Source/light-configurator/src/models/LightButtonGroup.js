import { makeAutoObservable } from 'mobx';
import { nanoid } from 'nanoid';

export default class LightButtonGroup {
  id;
  buttons = [];

  constructor() {
    this.id = nanoid();
    makeAutoObservable(this, {
      id: false
    });
  }

  isValid(lightData) {
    return this.buttons.every(g => g.isValid(lightData));
  }
}
