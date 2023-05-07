import { makeAutoObservable } from 'mobx';
import { nanoid } from 'nanoid';
import { remoteControllerButtonMap } from '../constants';

export default class RemoteControllerButton {
  id;
  buttonId = null;
  deviceNumber = null;
  enableDoubleClick = false;
  doubleClickDelay = 550;
  open = true;
  actions = [];
  controller;

  constructor(controller) {
    this.id = nanoid();
    this.deviceNumber = Math.floor(Math.random() * 65535) + 1;
    this.controller = controller;
    makeAutoObservable(this, {
      id: false,
      controller: false
    });
  }

  getConfigurationDeviceNumber = () => {
    return !this.controller.hasStandaloneCenterButton() && this.buttonId === 1 ? -1 : this.deviceNumber;
  }

  setButtonId = (value) => {
    this.buttonId = value;
    this.controller.updateButtonSelectList();
  }

  setOpen = (value) => {
    this.open = value;
  }

  setDeviceNumber = (value) => {
    this.deviceNumber = value;
  }

  setEnableDoubleClick  = (value) => {
    this.enableDoubleClick = value;
  }

  setDoubleClickDelay  = (value) => {
    this.doubleClickDelay = value;
  }

  isValid(configuration, device) {
    return this.buttonId && this.deviceNumber &&
      this.actions.length > 0 && this.actions.every(f => f.isValid(configuration, device)) &&
      (!this.enableDoubleClick || this.doubleClickDelay);
  }

  getDisplayName() {
    return this.buttonId ? remoteControllerButtonMap[this.buttonId].name : null;
  }
}
