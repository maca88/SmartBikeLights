import { makeAutoObservable } from 'mobx';
import { nanoid } from 'nanoid';

export default class LightButton {
  id;
  mode = null;
  name = null;

  constructor() {
    this.id = nanoid();
    makeAutoObservable(this, {
      id: false
    });
  }

  setMode = (value) => {
    this.mode = value;
  }

  setName = (value) => {
    this.name = value;
  }

  isValid() {
    return this.mode != null && (this.mode < 0 || this.name);
  }
}