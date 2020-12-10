import { makeAutoObservable } from 'mobx';
import LightButtonGroup from './LightButtonGroup';
import LightButton from './LightButton';

export default class LightPanel {
  buttonGroups = [];
  lightName = null;

  constructor(data) {
    makeAutoObservable(this, {});
    if (!data) {
      return;
    }

    this.lightName = data.shortName;
    data.buttonGroups.forEach(modeList => {
      const group = new LightButtonGroup();
      modeList.forEach(mode => {
        const button = new LightButton();
        button.mode = mode.id;
        button.name = mode.name;
        group.buttons.push(button);
      });
      this.buttonGroups.push(group);
    });
  }

  isValid() {
    return this.buttonGroups.every(g => g.isValid());
  }

  setLightName = (value) => {
    this.lightName = value;
  }
}