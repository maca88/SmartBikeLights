import { nanoid } from 'nanoid';
import { makeAutoObservable } from 'mobx';
import { 
  filterMap, batteryStateList, gpsAccuracyList, timerStateList, timespanTypeMap, speedUnitList, getBatteryOperator, 
  getBatteryValue, vehicleThreatList, distanceUnitList, setList
} from '../constants';
import addSeconds from 'date-fns/addSeconds';
import startOfToday from 'date-fns/startOfToday';
import format from 'date-fns/format';

const getTimespanPartName = (type, value, timeFormat) => {
  if (value === null) {
    return null;
  }

  return (
    type === '0' /* Time */
    ? format(addSeconds(startOfToday(), value), timeFormat === 0 /* 24H */ ? 'H:mm' : 'h:mm aa')
    : timespanTypeMap[type] + (
      value === 0 ? ''
      : value > 0 ? '+' + (value / 60) + ' min'
      : (value / 60) + ' min')
  );
};

const getSpeedName = (value, units) => {
  const speed = units === 0 /* Metric */
      ? value * 3.6
      : value * 2.236934;
  const unitsName = speedUnitList[units].name;

  return `${Math.round(speed * 100) / 100} ${unitsName}`; 
};

const getDistanceName = (value, units) => {
  const distance = units === 0 /* Metric */
      ? value
      : value * 3.2808;
  const unitsName = distanceUnitList[units].name;

  return `${Math.round(distance * 100) / 100} ${unitsName}`; 
};

const getOperatorFromValue = (value) => {
  return value === '[' ? '<'
    : value === ']' ? '>'
    : value;
};

const getOperatorValue = (operator) => {
  // Due to the Garmin Connect Mobile iOS bug for < and > characters we have to replace them:
  // https://forums.garmin.com/developer/connect-iq/i/bug-reports/garmin-connect-mobile-ios-does-not-accept-and-characters-for-an-alphanumeric-app-setting
  return operator === '<' ? '['
    : operator === '>' ? ']'
    : operator;
};

export default class Filter {
  id;
  type = null;
  operator = null;
  value = null;
  // Timeline fields
  fromType = null;
  fromValue = null;
  toType = null;
  toValue = null;
  // Position fields
  polygons = [];
  // Bike radar fields
  threatOperator = null;
  threat = null;
  // Ui properties
  open = true;

  constructor() {
    this.id = nanoid();
    makeAutoObservable(this, {
      id: false
    });
  }

  isValid(device) {
    switch (this.type) {
      case 'E':
        return this.fromType && this.fromValue !== null && !Number.isNaN(this.fromValue) && 
          this.toType && this.toValue !== null && !Number.isNaN(this.toValue);
      case 'F':
        return device.polygons && this.polygons.length;
      case 'I':
        return (!this.operator || this.isValidOperator(this.operator, this.value)) &&
          (!this.threatOperator || this.isValidOperator(this.threatOperator, this.threat));
      default:
        return this.type && this.isValidOperator(this.operator, this.value);
    }
  }

  isValidOperator(operator, value) {
    return value !== '' && value !== null && !Number.isNaN(value) && operator;
  }

  getConfigurationValue() {
    const getTimespanPartValue = (type, value) => {
      return type === '0' /* Time */ ? value : `${type}${value}`;
    };

    let config = this.type;
    if (this.type === 'F') {
      if (!this.polygons.length) {
        return null;
      }

      config += `${this.polygons.length}`;
      this.polygons.forEach(p => {
        p.vertexes.forEach(v => {
          config += `,${v[0]},${v[1]}`;
        });
      });

      return config;
    }

    if (this.type === 'E') {
      config += `${getTimespanPartValue(this.fromType, this.fromValue)},`;
      config += `${getTimespanPartValue(this.toType, this.toValue)}`;
      return config;
    }

    if (this.type === 'I') {
      config += this.operator ? `${getOperatorValue(this.operator)}${(this.value)}` : ']-1';
      config += this.threatOperator ? `${getOperatorValue(this.threatOperator)}${(this.threat)}` : ']-1';
      return config;
    }

    return `${config}${getOperatorValue(this.operator)}${this.value}`;
  }

  get hasOperator() {
    return this.type && this.type !== 'E' /* Timespan */ && this.type !== 'F' /* Position */;
  }

  getDisplayName(context) {
    if (!this.type && this.type !== 'E' /* Timespan */) {
      return null;
    }

    let name = filterMap[this.type] + ' ';
    if (this.type === 'E' /* Timespan */) {
      if (this.fromValue !== null && this.toValue !== null) {
        name += 'from ' + getTimespanPartName(this.fromType, this.fromValue, context.timeFormat) + ' to ';
        name += getTimespanPartName(this.toType, this.toValue, context.timeFormat);
      }
    } else if (this.type === 'F' /* Position */) {
      if (this.polygons.length) {
        name += this.polygons.length + ' polygons';
      }
    } else if (this.type === 'I' /* Bike radar */) {
      const isRangeValid = this.isValidOperator(this.operator, this.value);
      if (isRangeValid) {
        name += `Range ${this.operator} ${getDistanceName(this.value, context.units)} `;
      }

      if (this.isValidOperator(this.threatOperator, this.threat)) {
        if (isRangeValid) {
          name += 'AND ';
        }

        name += `Threat ${this.threatOperator} ${vehicleThreatList[this.threat]}`;
      }

      if (this.operator === null && this.threatOperator === null) {
        name += 'Any vehicle';
      }
    } else if (this.value !== null && !Number.isNaN(this.value)) {
      switch (this.type) {
        case 'A': // Acceleration
          name += ((this.operator || '') + ' ');
          name += (this.value + '% per second');
          break;
        case 'B': // Battery state
          name += ((getBatteryOperator(this.operator) || '') + ' ');
          name += batteryStateList[getBatteryValue(this.value)];
          break;
        case 'C': // Speed
          name += ((this.operator || '') + ' ');
          name += getSpeedName(this.value, context.units);
          break;
        case 'G': // GPS Accuracy
          name += ((this.operator || '') + ' ');
          name += gpsAccuracyList[this.value];
          break;
        case 'H': // Timer state
          name += ((this.operator || '') + ' ');
          name += timerStateList[this.value];
          break;
        case 'J': // Start location
          name += setList.find(o => o.id === this.value)?.name;
          break;
        default:
          break;
      }
    }

    return name;
  }

  setType = (value) => {
    this.type = value;
  }

  setOperator = (value) => {
    this.operator = getOperatorFromValue(value);
  }

  setValue = (value) => {
    this.value = value;
  }

  setFromType = (value) => {
    this.fromType = value;
  }

  setFromValue = (value) => {
    this.fromValue = value;
  }

  setToType = (value) => {
    this.toType = value;
  }

  setToValue = (value) => {
    this.toValue = value;
  }

  setThreat = (value) => {
    this.threat = value;
  }

  setThreatOperator = (value) => {
    this.threatOperator = getOperatorFromValue(value);
  }

  setOpen = (value) => {
    this.open = value;
  }
}