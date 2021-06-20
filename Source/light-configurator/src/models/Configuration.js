import { makeAutoObservable } from 'mobx';
import FilterGroup from './FilterGroup';
import Filter from './Filter';
import Polygon from './Polygon';
import LightPanel from './LightPanel';
import LightButtonGroup from './LightButtonGroup';
import LightButton from './LightButton';
import LightSettings from './LightSettings';
import { getLight } from '../constants';

const defaultFilter = new Filter();
defaultFilter.type = 'D';
defaultFilter.operator = '=';
defaultFilter.value = '1';

const getDefaultGroupConfigurationValue = (lightMode) => {
  let group = new FilterGroup(true);
  group.lightMode = lightMode;
  group.filters.push(defaultFilter);
  return group.getConfigurationValue();
};

const parseNumber = (chars, index, resultIndex) => {
  let stringValue = null;
  let i;
  let isFloat = false;
  for (i = index; i < chars.length; i++) {
    const char = chars[i];
    const charNumber = char.charCodeAt(0);
    if (charNumber === 46 /* . */) {
      isFloat = true;
    } else if (charNumber !== 45 /* - */ && (charNumber > 57 /* 9 */ || charNumber < 48 /* 0 */)) {
      break;
    }

    stringValue = stringValue === null ? char : stringValue + char;
  }

  resultIndex[0] = i;
  return stringValue === null ? null
    : isFloat ? parseFloat(stringValue)
    : parseInt(stringValue);
};

const parseNumberArray = (chars, index, resultIndex) => {
  const left = parseNumber(chars, index, resultIndex);
  if (left === null) {
    return null;
  }

  const right = parseNumber(chars, resultIndex[0] + 1, resultIndex);
  return [left, right];
};

const parseTitle = (chars, index, resultIndex) => {
  let stringValue = null;
  let i;
  for (i = index; i < chars.length; i++) {
    const char = chars[i];
    if (char === ':' || char === '#' || char === '|') {
        break;
    }

    stringValue = stringValue === null ? char : stringValue + char;
  }

  resultIndex[0] = i;
  return stringValue;
};

const parseTimespanPart = (chars, index, filterResult, data, dataIndex) => {
  const char = chars[index];
  const type = char !== 's' /* Sunset */ && char !== 'r' /* Sunrise */
    ? '0'
    : char;
  if (type !== '0') {
      index++;
  }

  data[dataIndex] = type;
  data[dataIndex + 1] = parseNumber(chars, index, filterResult);
};

const parsePolygons = (chars, index, filterResult) => {
  filterResult[1] = null; /* Filter operator */
  // The first value represents the total number of polygons
  const data = new Array(parseNumber(chars, index, filterResult) * 8);
  let dataIndex = 0;
  index = filterResult[0] + 1;
  while (dataIndex < data.length) {
      data[dataIndex] = parseNumber(chars, index, filterResult);
      dataIndex++;
      index = filterResult[0] + 1;
  }

  return data;
};

const parseBikeRadar = (chars, index, filterResult) => {
  filterResult[1] = chars[index]; // Filter operator
  const data = new Array(3);
  data[0] = parseNumber(chars, index + 1, filterResult);
  data[1] = chars[filterResult[0]]; // Threat operator
  data[2] = parseNumber(chars, filterResult[0] + 1, filterResult);

  return data;
};

const parseGenericFilter = (charNumber, chars, index, filterResult) => {
  filterResult[1] = chars[index]; // Filter operator

  return charNumber === 75 /* Profile name */
    ? parseTitle(chars, index + 1, filterResult)
    : parseNumber(chars, index + 1, filterResult);
};

const parseTimespan = (chars, index, filterResult) => {
  const data = new Array(4);
  filterResult[1] = null; /* Filter operator */
  parseTimespanPart(chars, index, filterResult, data, 0);
  parseTimespanPart(chars, filterResult[0] + 1 /* Skip , */, filterResult, data, 2);

  return data;
};

const parseLightPanel = (chars, i, filterResult) => {
  const totalButtons = parseNumber(chars, i, filterResult);
  if (!totalButtons) {
      return null;
  }

  if (chars[filterResult[0]] === ':') {
    return parseLightSettings(totalButtons, chars, filterResult);
  }

  const panel = new LightPanel();
  parseNumber(chars, filterResult[0] + 1, filterResult);
  panel.lightName = parseTitle(chars, filterResult[0] + 1, filterResult);
  i = filterResult[0];
  while (i < chars.length) {
    const char = chars[i];
    if (char === '#') {
        break;
    }

    if (char === '|') {
        const lightButtonGroup = new LightButtonGroup();
        const numberOfButtons = parseNumber(chars, filterResult[0] + 1, filterResult); // Number of buttons in the group
        for (let j = 0; j < numberOfButtons; j++) {
            let lightButton = new LightButton();
            lightButton.name = parseTitle(chars, filterResult[0] + 1, filterResult);
            lightButton.mode = parseNumber(chars, filterResult[0] + 1, filterResult);
            lightButtonGroup.buttons.push(lightButton);
        }

        i = filterResult[0];
        panel.buttonGroups.push(lightButtonGroup);
    } else {
        throw new Error('Invalid LightPanel configuration');
    }
  }

  return panel;
}

const parseLightSettings = (totalButtons, chars, filterResult) => {
  const settings = new LightSettings();
  settings.lightName = parseTitle(chars, filterResult[0] + 1, filterResult);
  for (let j = 0; j < totalButtons; j++) {
    let lightButton = new LightButton();
    lightButton.name = parseTitle(chars, filterResult[0] + 1, filterResult);
    lightButton.mode = parseNumber(chars, filterResult[0] + 1, filterResult);
    settings.buttons.push(lightButton);
  }

  return settings;
};

const parseFilters = (chars, i, lightMode, filterResult) => {
  const totalFilters = parseNumber(chars, i, filterResult);
  if (totalFilters === null) {
    return null;
  }

  const groupDataLength = lightMode ? 4 : 2;
  const totalGroups = parseNumber(chars, filterResult[0] + 1, filterResult);
  const data = new Array((totalFilters * 3) + totalGroups * groupDataLength);
  i = filterResult[0];
  let dataIndex = 0;

  while (i < chars.length) {
    const charNumber = chars[i].charCodeAt(0);
    if (charNumber === 35 /* # */) {
      break;
    }

    if (charNumber === 124 /* | */) {
      data[dataIndex] = parseTitle(chars, i + 1, filterResult); // Group title
      data[dataIndex + 1] = parseNumber(chars, filterResult[0] + 1, filterResult); // Number of filters in the group
      if (lightMode) {
        data[dataIndex + 2] = parseNumber(chars, filterResult[0] + 1 /* Skip : */, filterResult); // The light mode id
        if (chars[filterResult[0]] === ':') { // For back compatibility
          data[dataIndex + 3] = parseNumber(chars, filterResult[0] + 1 /* Skip : */, filterResult); // The min active filter time
        }
      }

      dataIndex += groupDataLength;
      i = filterResult[0];
    } else if (charNumber >= 65 /* A */ && charNumber <= 90 /* Z */) {
      const filterValue = charNumber === 69 /* E */ ? parseTimespan(chars, i + 1, filterResult)
          : charNumber === 70 /* F */ ? parsePolygons(chars, i + 1, filterResult)
          : charNumber === 73 /* I */ ? parseBikeRadar(chars, i + 1, filterResult)
          : parseGenericFilter(charNumber, chars, i + 1, filterResult);

      data[dataIndex] = chars[i]; // Filter type
      data[dataIndex + 1] = filterResult[1]; // Filter operator
      data[dataIndex + 2] = filterValue; // Filter value
      dataIndex += 3;
      i = filterResult[0];
    } else {
      i++;
      filterResult[0] = i;
    }
  }

  return data;
};

const parseToFilter = (type, operator, value) => {
  let filter = new Filter();
  filter.open = false;
  filter.type = type;
  filter.setOperator(operator);
  if (type === 'E' /* Timespan */) {
    filter.fromType = value[0];
    filter.fromValue = value[1];
    filter.toType = value[2];
    filter.toValue = value[3];
  } else if (type === 'F' /* Position */) {
    for (let i = 0; i < value.length; i += 8) {
      let polygon = new Polygon();
      let endIndex = i + 8;
      for (let j = i; j < endIndex;) {
        polygon.vertexes.push([value[j++], value[j++]]);
      }

      filter.polygons.push(polygon);
    }
  } else if (type === 'I' /* Bike radar */) {
    if (value[0] >= 0) {
      filter.value = value[0];
    } else {
      filter.setOperator(null);
    }

    if (value[2] >= 0) {
      filter.setThreatOperator(value[1]);
      filter.threat = value[2];
    }
  } else {
    filter.value = value;
  }

  return filter;
};

const parseToFilterGroups = (chars, i, hasLightMode, filterResult) => {
  let filterGroups = [];
  const values = parseFilters(chars, i, hasLightMode, filterResult);
  if (!values) {
    return filterGroups;
  }

  for (let i = 0; i < values.length;) {
    let filterGroup = new FilterGroup(hasLightMode);
    filterGroup.open = false;
    filterGroup.name = values[i++];
    let totalFilters = values[i++];
    if (hasLightMode) {
      filterGroup.lightMode = values[i++];
      const minActiveTime = values[i++];
      filterGroup.minActiveTime = minActiveTime !== null && minActiveTime > 1 ? minActiveTime : null;
    }

    let endIndex = i + totalFilters * 3;
    for (let j = i; j < endIndex;) {
      filterGroup.filters.push(parseToFilter(values[j++], values[j++], values[j++]));
    }

    i = endIndex;
    filterGroups.push(filterGroup);
  }

  return filterGroups;
};

export default class Configuration {

  device = null;
  units = 0;
  timeFormat = 0;
  globalFilterGroups = [];
  headlight = null;
  headlightModes = null;
  headlightFilterGroups = [];
  headlightDefaultMode = null;
  headlightPanel = null;
  headlightSettings = null;
  taillight = null;
  taillightModes = null;
  taillightFilterGroups = [];
  taillightDefaultMode = null;
  taillightPanel = null;
  taillightSettings = null;
  useIndividualNetwork = false;
  headlightDeviceNumber = null;
  taillightDeviceNumber = null;

  constructor() {
    makeAutoObservable(this, {
    });
  }

  static parse(value, deviceList) {
    if (!value || value.length === 0) {
      return null;
    }

    const filterResult = [0 /* next index */, 0 /* operator type */];
    const configuration = new Configuration();
    configuration.globalFilterGroups = parseToFilterGroups(value, 0, false, filterResult);

    configuration.headlightModes = parseNumberArray(value, filterResult[0] + 1, filterResult);
    let filterGroups = parseToFilterGroups(value, filterResult[0] + 1, true, filterResult);
    let defaultGroup;
    if (filterGroups.length) {
      defaultGroup = filterGroups.splice(filterGroups.length - 1, 1)[0];
      configuration.headlightDefaultMode = defaultGroup.lightMode;
    }

    configuration.headlightFilterGroups = filterGroups;

    configuration.taillightModes = parseNumberArray(value, filterResult[0] + 1, filterResult);
    filterGroups = parseToFilterGroups(value, filterResult[0] + 1, true, filterResult);
    if (filterGroups.length) {
      defaultGroup = filterGroups.splice(filterGroups.length - 1, 1)[0];
      configuration.taillightDefaultMode = defaultGroup.lightMode;
    }

    configuration.taillightFilterGroups = filterGroups;

    let panel = parseLightPanel(value, filterResult[0] + 1, filterResult);
    if (panel instanceof LightSettings) {
      configuration.headlightSettings = panel;
    } else {
      configuration.headlightPanel = panel;
    }

    panel = parseLightPanel(value, filterResult[0] + 1, filterResult);
    if (panel instanceof LightSettings) {
      configuration.taillightSettings = panel;
    } else {
      configuration.taillightPanel = panel;
    }

    const useIndividualNetwork = parseNumber(value, filterResult[0] + 1, filterResult);
    if (useIndividualNetwork === null) {
      // This is an old configuration
      configuration.device = parseTitle(value, filterResult[0], filterResult);
    } else {
      configuration.useIndividualNetwork = useIndividualNetwork === 1;
      configuration.headlightDeviceNumber = parseNumber(value, filterResult[0] + 1, filterResult);
      configuration.taillightDeviceNumber = parseNumber(value, filterResult[0] + 1, filterResult);
      configuration.device = parseTitle(value, filterResult[0] + 1, filterResult);
    }

    configuration.headlight = parseNumber(value, filterResult[0] + 1, filterResult);
    configuration.taillight = parseNumber(value, filterResult[0] + 1, filterResult);
    configuration.units = parseNumber(value, filterResult[0] + 1, filterResult);
    configuration.timeFormat = parseNumber(value, filterResult[0] + 1, filterResult);

    return configuration.isValid(deviceList) ? configuration : null;
  }

  isValid(deviceList) {
    const device = deviceList.find(l => l.id === this.device);
    return device &&
      this.globalFilterGroups.every(g => g.isValid(device, null)) && (
        (this.headlight !== null || this.taillight !== null) &&
        this.islightValid(this.headlight, false, this.headlightFilterGroups, this.headlightDefaultMode, device) &&
        this.islightValid(this.taillight, true, this.taillightFilterGroups, this.taillightDefaultMode, device)
      ) &&
      this.isItemValid(this.headlightPanel, device.touchScreen) &&
      this.isItemValid(this.taillightPanel, device.touchScreen) &&
      this.isItemValid(this.headlightSettings, device.settings) &&
      this.isItemValid(this.taillightSettings, device.settings) &&
      this.isIndividualNetworkValid(device);
  }

  isIndividualNetworkValid(device) {
    if (!this.useIndividualNetwork || !device.highMemory) {
      return true;
    }

    return (this.headlight === null || this.headlightDeviceNumber !== null) && 
      (this.taillight === null || this.taillightDeviceNumber !== null);
  }

  isItemValid(item, validate) {
    return !validate || item == null || item.isValid();
  }

  islightValid(light, taillight, lightFilterGroups, lightDefaultMode, device) {
    if (light === null) {
      return true;
    }

    const lightData = getLight(taillight, light);
    if (lightData.individualNetworkOnly && (!this.useIndividualNetwork || !device.highMemory)) {
      return false;
    }

    return lightData.modes != null && lightFilterGroups.every(g => g.isValid(device, lightData.modes)) &&
          (
            (!lightFilterGroups.length && !this.globalFilterGroups.length) ||
            lightDefaultMode !== null
          );
  }

  getConfigurationValue(deviceList) {
    if (!this.isValid(deviceList)) {
      return null;
    }

    const device = deviceList.find(l => l.id === this.device);
    let config = `${this.getFilterGroupsConfigurationValue(this.globalFilterGroups, null)}`;
    config += `#${this.getNumberArray(this.headlightModes)}`;
    config += `#${this.headlight === null ? '' : this.getFilterGroupsConfigurationValue(this.headlightFilterGroups, this.headlightDefaultMode)}`;
    config += `#${this.getNumberArray(this.taillightModes)}`;
    config += `#${this.taillight === null ? '' : this.getFilterGroupsConfigurationValue(this.taillightFilterGroups, this.taillightDefaultMode)}`;
    config += `#${this.getLightPanelOrSettingsConfigurationValue(this.headlightPanel, this.headlightSettings, device)}`;
    config += `#${this.getLightPanelOrSettingsConfigurationValue(this.taillightPanel, this.taillightSettings, device)}`;
    config += `#${this.getIndividualNetworkConfigurationValue(device)}`;
    config += `#${(this.device)}`;
    config += `#${(this.headlight === null ? '' : this.headlight)}`;
    config += `#${(this.taillight === null ? '' : this.taillight)}`;
    config += `#${(this.units)}`;
    config += `#${(this.timeFormat)}`;

    return config;
  }

  getNumberArray(value) {
    if (value == null) {
      return '';
    }

    return `${value[0]},${value[1]}`;
  }

  getIndividualNetworkConfigurationValue(device) {
    if (!device || !device.highMemory || !this.useIndividualNetwork) {
      return '0::';
    }

    let config = this.useIndividualNetwork ? '1' : '0';
    config += ':';
    config += this.headlight === null || this.headlightDeviceNumber === null ? '' : this.headlightDeviceNumber;
    config += ':';
    config += this.taillight === null || this.taillightDeviceNumber === null ? '' : this.taillightDeviceNumber;

    return config;
  }

  getLightPanelOrSettingsConfigurationValue(lightPanel, lightSettings, device) {
    if (!device) {
      return '';
    }

    if (device.settings && lightSettings && lightSettings.buttons.length) {
      return this.getLightSettingsConfigurationValue(lightSettings);
    }

    if (device.touchScreen && lightPanel && lightPanel.buttonGroups.length) {
      return this.getLightPanelConfigurationValue(lightPanel);
    }

    return '';
  }

  getLightSettingsConfigurationValue(lightSettings) {
    const lightName = lightSettings.lightName ? lightSettings.lightName : '';
    const totalButtons = lightSettings.buttons.length;
    let buttons = '';
    for (let i = 0; i < lightSettings.buttons.length; i++) {
      const button = lightSettings.buttons[i];
      buttons += `|${button.name}:${button.mode}`;
    }

    return `${totalButtons}:${lightName}${buttons}`;
  }

  getLightPanelConfigurationValue(lightPanel) {
    const lightName = lightPanel.lightName ? lightPanel.lightName : '';
    let buttonGroups = '';
    let totalButtons = 0;
    for (let i = 0; i < lightPanel.buttonGroups.length; i++) {
      const buttons = lightPanel.buttonGroups[i].buttons;
      totalButtons += buttons.length;
      buttonGroups += `|${buttons.length}`;
      for (let j = 0; j < buttons.length; j++) {
        let button = buttons[j];
        buttonGroups += `,${(button.mode < 0 ? '' : button.name)}:${button.mode}`;
      }
    }

    return `${totalButtons},${lightPanel.buttonGroups.length}:${lightName}${buttonGroups}`;
  }

  getFilterGroupsConfigurationValue(filterGroups, defaultMode) {
    if (!filterGroups.length && defaultMode === null) {
      return '';
    }

    let config = '';
    let totalFilters = 0;
    let totalGroups = filterGroups.length;
    let defaultGroupConfig = ''
    if (defaultMode !== null) {
      totalFilters++;
      totalGroups++;
      defaultGroupConfig = `|${getDefaultGroupConfigurationValue(defaultMode)}`;
    }

    filterGroups.forEach(g => {
      totalFilters += g.filters.length;
      config += `|${g.getConfigurationValue()}`;
    });

    return `${totalFilters},${totalGroups}${config}${defaultGroupConfig}`;
  }

  setDevice = (value) => {
    this.device = value;
  }

  setUnits = (value) => {
    this.units = value;
  }

  setTimeFormat = (value) => {
    this.timeFormat = value;
  }

  setHeadlight = (value) => {
    this.headlight = value;
  }

  setHeadlightModes = (value) => {
    this.headlightModes = value;
  }

  setHeadlightDefaultMode = (value) => {
    this.headlightDefaultMode = value;
  }

  setHeadlightPanel = (value) => {
    this.headlightPanel = value;
  }

  setHeadlightSettings = (value) => {
    this.headlightSettings = value;
  }

  setTaillight = (value) => {
    this.taillight = value;
  }

  setTaillightModes = (value) => {
    this.taillightModes = value;
  }

  setTaillightDefaultMode = (value) => {
    this.taillightDefaultMode = value;
  }

  setTaillightPanel = (value) => {
    this.taillightPanel = value;
  }

  setTaillightSettings = (value) => {
    this.taillightSettings = value;
  }

  setUseIndividualNetwork = (value) => {
    this.useIndividualNetwork = value;
  }

  setHeadlightDeviceNumber = (value) => {
    this.headlightDeviceNumber = Number.isNaN(value) ? null : value;
  }

  setTaillightDeviceNumber = (value) => {
    this.taillightDeviceNumber = Number.isNaN(value) ? null : value;
  }
}