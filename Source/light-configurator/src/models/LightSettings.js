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
        button.name = mode.buttonName ?? mode.name;
        this.buttons.push(button);
      });
    });
  }

  isValid(lightData) {
    return this.buttons.every(g => g.isValid(lightData));
  }

  setLightName = (value) => {
    this.lightName = value;
  }
}
