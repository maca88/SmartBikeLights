import { makeAutoObservable } from 'mobx';
import { nanoid } from 'nanoid';
import { getLight, buttonActionTypeMap, buttonTriggerMap } from '../constants';
import LightMode from './LightMode';
import LightModeCycleBehavior from './LightModeCycleBehavior';

export default class RemoteControllerButtonAction {
  id;
  actionType = null;
  triggerId = null;
  toneId = null;

  open = true;
  conditions = [];
  /* Cycle light modes */
  headlightTapBehavior = new LightModeCycleBehavior();
  taillightTapBehavior = new LightModeCycleBehavior();
  /* Change light mode */
  headlightMode = new LightMode();
  taillightMode = new LightMode();
  /* Change configuration */
  configurationId = null;
  /* Play tone */
  toneTypeId = null;
  repeatCount = 1;
  tones = [];
  toneSequence = [];

  constructor() {
    this.id = nanoid();
    makeAutoObservable(this, {
      id: false
    });
  }

  setActionType = (value) => {
    this.actionType = value;
  }

  setTriggerId = (value) => {
    this.triggerId = value;
  }

  setToneId = (value) => {
    this.toneId = value;
  }

  setConfigurationId = (value) => {
    this.configurationId = value;
  }

  setToneTypeId = (value) => {
    this.toneTypeId = value;
  }

  setRepeatCount = (value) => {
    this.repeatCount = value;
  }

  setHeadlightTapBehavior = (value) => {
    this.headlightTapBehavior = value;
  }

  setTaillightTapBehavior = (value) => {
    this.taillightTapBehavior = value;
  }

  setOpen = (value) => {
    this.open = value;
  }

  isValid(configuration, device) {
    return this.actionType && this.triggerId &&
      (this.actionType === 1 /* Cycle light modes */ ? this.validateCycleLightModes(configuration)
      : this.actionType === 2 /* Change light mode */ ? this.validateChangeLightMode(configuration)
      : this.actionType === 3 /* Change configuration */ ? this.configurationId != null
      : this.actionType === 4 /* Play tone */ ? this.validatePlayTone()
      : false) &&
      this.conditions.every(f => f.isValid(device));
  }

  getDisplayName() {
    return this.actionType && this.triggerId
      ? `${buttonActionTypeMap[this.actionType]} - ${buttonTriggerMap[this.triggerId]}`
      : null;
  }

  validateCycleLightModes(configuration) {
    const headlightId = configuration.headlight;
    const taillightId = configuration.taillight;
    const headlight = headlightId ? getLight(false, headlightId) : null;
    const taillight = taillightId ? getLight(true, taillightId) : null;
    if (!taillight && !headlight) {
      return false;
    }

    if (headlight && !this.headlightTapBehavior.isValid(headlight)) {
      return false;
    }

    if (taillight && !this.taillightTapBehavior.isValid(taillight)) {
      return false;
    }

    return true;
  }

  validateChangeLightMode(configuration) {
    const headlightId = configuration.headlight;
    const taillightId = configuration.taillight;
    const headlight = headlightId ? getLight(false, headlightId) : null;
    const taillight = taillightId ? getLight(true, taillightId) : null;
    if ((!headlight && !taillight) || (this.headlightMode.controlMode == null && this.taillightMode.controlMode == null)) {
      return false;
    }

    return this.headlightMode.isValid() && this.taillightMode.isValid();
  }

  validatePlayTone() {
    if (this.toneTypeId === 1 /* Built-in */) {
      return this.toneId != null;
    }

    return this.repeatCount && this.tones.length && this.tones.every(n => n.isValid()) &&
      this.toneSequence.length && this.toneSequence.every(n => n.isValid());
  }
}
