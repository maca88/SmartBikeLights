import { makeAutoObservable } from 'mobx';

export default class Tone {
  id;
  name = null;
  frequency = null;
  duration = null;

  constructor(id) {
    this.id = id;
    makeAutoObservable(this, {
      id: false
    });
  }

  setName = (value) => {
    this.name = value;
  }

  setFrequency = (value) => {
    this.frequency = value;
  }

  setDuration = (value) => {
    this.duration = value;
  }

  isValid() {
    return this.name != null && this.frequency && this.duration;
  }
}
