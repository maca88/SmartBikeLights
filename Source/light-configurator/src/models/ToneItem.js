import { makeAutoObservable } from 'mobx';
import { nanoid } from 'nanoid';

export default class ToneItem {
  id;
  toneId = null;

  constructor() {
    this.id = nanoid();
    makeAutoObservable(this, {
      id: false
    });
  }

  setToneId = (value) => {
    this.toneId = value;
  }

  isValid() {
    return this.toneId != null;
  }
}
