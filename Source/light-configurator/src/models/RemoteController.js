import { makeAutoObservable } from 'mobx';
import { nanoid } from 'nanoid';
import { remoteControllerMap } from '../constants';

export default class RemoteController {
  id;
  controllerId = null;
  name = null;
  open = true;
  buttons = [];
  buttonSelectList = [];

  constructor() {
    this.id = nanoid();
    makeAutoObservable(this, {
      id: false
    });
  }

  setControllerId = (value) => {
    this.controllerId = value;
    this.updateButtonSelectList();
  }

  updateButtonSelectList = () => {
    if (this.controllerId) {
      const controller = remoteControllerMap[this.controllerId];
      if (!controller.standaloneCenterButton && !this.buttons.some(b => b.buttonId != null && b.buttonId !== 1 /* Center */)) {
        this.buttonSelectList = controller.buttons.filter(b => b.id !== 1 /* Center */);
      } else {
        this.buttonSelectList = [...controller.buttons];
      }

      if (!this.name) {
        this.name = controller.shortName;
      }
    } else {
      this.buttonSelectList = [];
      this.name = null;
    }
  }

  hasStandaloneCenterButton = () => {
    return this.controllerId ? remoteControllerMap[this.controllerId]?.standaloneCenterButton === true : false;
  }

  setName = (value) => {
    this.name = value;
  }

  setOpen = (value) => {
    this.open = value;
  }

  getDisplayName() {
    return this.controllerId ? remoteControllerMap[this.controllerId].name : null;
  }

  isValid(configuration, device) {
    return this.controllerId != null && this.name && this.buttons.length > 0 && this.buttons.every(f => f.isValid(configuration, device));
  }
}
