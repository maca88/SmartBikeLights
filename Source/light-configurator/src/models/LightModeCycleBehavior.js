import { makeAutoObservable } from 'mobx';
import { controlModeList } from '../constants';

export default class LightModeCycleBehavior {
  lightModes = null;
  manualModeBehavior = 0;
  controlModes = [];

  constructor() {
    makeAutoObservable(this, {});
    controlModeList.forEach(item => this.controlModes.push(item.id));
  }

  isValid = (lightData) => {
    if ((!this.lightModes || !this.lightModes.length) && this.manualModeBehavior === 1) {
      return false;
    }

    if (this.lightModes && lightData) {
      return this.lightModes.every(lm => lightData.modes.find(m => m.id === lm) !== undefined) && this.controlModes.indexOf(2 /* MANUAL*/) !== -1;
    }

    return true;
  }

  containsManualMode = () => {
    return this.controlModes && this.controlModes.indexOf(2 /* MANUAL */) >= 0;
  }

  setManualModeBehavior = (value) => {
    this.manualModeBehavior = value;
    if (value === 0) {
      this.lightModes = null;
    }
  }

  setControlModes = (value) => {
    if (!value || value.indexOf(2 /* MANUAL */) < 0) {
      this.lightModes = null;
      this.manualModeBehavior = 0;
    }

    this.controlModes = value;
  }

  setLightModes = (value) => {
    this.lightModes = value;
  }
}
