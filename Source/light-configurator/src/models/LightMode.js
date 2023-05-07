import { makeAutoObservable } from 'mobx';
import { controlModeMap } from '../constants'

export default class LightMode {
  controlMode = null;
  lightMode = null;
  operator = null;

  constructor() {
    makeAutoObservable(this, {});
  }

  setControlMode = (value) => {
    this.controlMode = value;
    if (value == null) {
      this.operator = null;
    } else if (!this.operator) {
      this.operator = '=';
    }
  }

  setOperator = (value) => {
    this.operator = value;
  }

  setLightMode = (value) => {
    this.lightMode = value;
  }

  isManual = () => {
    return this.controlMode === 2 /* Manual */;
  }

  isValid = () => {
    if (this.isManual() && this.lightMode == null) {
      return false;
    }

    return this.controlMode == null || this.operator != null;
  }

  getDisplayName = (lightType) => {
    if (this.controlMode == null) {
      return '';
    }

    let name = lightType === 0 ? "HL " : "TL ";
    name += (this.operator === '=') ? this.operator : '!=';
    name += ` ${controlModeMap[this.controlMode]}`;

    return name;
  }

  getConfigurationValue = () => {
    if (this.controlMode == null) {
      return '';
    }

    return `${this.controlMode}${this.operator}:${(this.isManual() ? this.lightMode : '')}`;
  }
}
