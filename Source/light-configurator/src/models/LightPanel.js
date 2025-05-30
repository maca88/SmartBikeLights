import { makeAutoObservable } from 'mobx';
import LightButtonGroup from './LightButtonGroup';
import LightButton from './LightButton';

export default class LightPanel {
  buttonGroups = [];
  lightName = null;
  buttonColor = 0; /* Activity color */
  buttonTextColor = 0xFFFFFF; /* White */
  groupNameVisibility = -1; /* Not visible */

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

  isValid(lightData) {
    return this.buttonGroups.every(g => g.isValid(lightData));
  }

  setLightName = (value) => {
    this.lightName = value;
  }

  setButtonColor = (value) => {
    this.buttonColor = value;
  }

  setButtonTextColor = (value) => {
    this.buttonTextColor = value;
  }

  setGroupNameVisibility = (value) => {
    this.groupNameVisibility = value;
  }
}
