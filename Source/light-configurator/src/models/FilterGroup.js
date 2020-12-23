import { nanoid } from 'nanoid';
import { makeAutoObservable } from 'mobx';

export default class FilterGroup {
  _hasLightMode;
  id;
  name = null;
  filters = [];
  lightMode = null;
  // Ui properties
  open = true;

  constructor(hasLightMode) {
    this._hasLightMode = hasLightMode;
    this.id = nanoid();
    makeAutoObservable(this, {
      id: false
    });
  }

  get displayName() {
    return 'Group ' + (this.name || '');
  }

  getConfigurationValue() {
    let config = `${(this.name || '')}:${this.filters.length}`;
    if (this._hasLightMode) {
      config += `:${this.lightMode}`;
    }

    this.filters.forEach(f => {
      config += `${(f.getConfigurationValue() || '')}`;
    });

    return config;
  }

  isValid() {
    if ((this._hasLightMode && this.lightMode === null) || !this.filters.length) {
      return false;
    }

    return this.filters.every(f => f.isValid());
  }

  setName = (value) => {
    if (value.length > 6) {
      return;
    }

    this.name = value.replace(/[^a-z0-9]/gi,'');
  }

  setLightMode = (value) => {
    this.lightMode = value;
  }

  setOpen = (value) => {
    this.open = value;
  }

  getDisplayName(lightModes) {
    var name = 'Group';
    if (this.name) {
      name += ' Name: ' + this.name;
    }

    if (lightModes && this.lightMode !== null) {
      name += ' Light Mode: ' + lightModes.find(m => m.id === this.lightMode)?.name;
    }

    return name;
  }
}