import { makeAutoObservable } from 'mobx';
import LightButton from './LightButton';

export default class LightSettings {
  buttons = [];
  lightName = null;

  constructor(data) {
    makeAutoObservable(this, {});
    if (!data) {
      return;
    }

    this.lightName = data.shortName;
    data.buttonGroups.forEach(modeList => {
      modeList.forEach(mode => {
        if (mode.id < 0) {
          return;
        }

        const button = new LightButton();
        button.mode = mode.id;
        button.name = mode.name;
        this.buttons.push(button);
      });
    });
  }

  isValid() {
    return this.buttons.every(g => g.isValid());
  }

  setLightName = (value) => {
    this.lightName = value;
  }
}