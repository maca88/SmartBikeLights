export const deviceList = [
  { id: 'B2713', name: 'Edge 1030', polygons: true, touchScreen: true },
  { id: 'B3095', name: 'Edge 1030 / Bontrager', polygons: true, touchScreen: true },
  { id: 'B3570', name: 'Edge 1030 Plus', polygons: true, touchScreen: true },
  { id: 'B1836', name: 'Edge 1000 / Explore', polygons: true, touchScreen: true },
  { id: 'B3011', name: 'Edge Explore', polygons: true, touchScreen: true },
  { id: 'B3122', name: 'Edge 830', polygons: true, touchScreen: true },
  { id: 'B2530', name: 'Edge 820 / Explore', polygons: true, touchScreen: true },
  { id: 'B3121', name: 'Edge 530', polygons: true, touchScreen: false },
  { id: 'B3112', name: 'Edge 520 Plus', polygons: true, touchScreen: false },
  { id: 'B2067', name: 'Edge 520', polygons: false, touchScreen: false },
  { id: 'B3558', name: 'Edge 130 Plus', polygons: false, touchScreen: false },
  { id: 'B2909', name: 'Edge 130', polygons: false, touchScreen: false }
];

let map = {};
deviceList.forEach(item => map[item.id] = item);

export const deviceMap = map;

export const isTouchScreen = (device) => {
  return device && deviceMap[device] && deviceMap[device].touchScreen;
};

export const filterList = [
  { id: 'A', name: 'Acceleration' },
  { id: 'B', name: 'Light Battery' },
  { id: 'C', name: 'Speed' },
  { id: 'E', name: 'Timespan' },
  { id: 'F', name: 'Position' },
  { id: 'G', name: 'GPS accuracy' }
];

map = {};
filterList.forEach(item => map[item.id] = item.name);

export const filterMap = map;

export const timespanTypeList = [
  { id: '0', name: 'UTC Time' },
  { id: 'r', name: 'Sunrise' },
  { id: 's', name: 'Sunset' }
];

map = {};
timespanTypeList.forEach(item => map[item.id] = item.name);

export const timespanTypeMap = map;

export const unitList = [
  { id: 0, name: 'Metric (km/h)' },
  { id: 1, name: 'Statute (MPH)' },
];

export const speedUnitList = [
  { id: 0, name: 'km/h' },
  { id: 1, name: 'MPH' },
];

export const timeFormatList = [
  { id: 0, name: '24h' },
  { id: 1, name: '12h' },
];

export const operatorList = [
  { id: '=', name: 'Equal to' },
  { id: '>', name: 'Greater than' },
  { id: '<', name: 'Lower than' }
];

export const batteryStateList = [
  null,
  'Bad',
  'Low',
  'Ok',
  'Good',
  'New'
];

export const gpsAccuracyList = [
  'N/A',
  'Last',
  'Poor',
  'Ok',
  'Good'
];

const lightModes = [
  { id: 0, name: 'Off' },
  { id: 1, name: 'Steady beam 81-100% intensity' },
  { id: 2, name: 'Steady beam 61-80% intensity' },
  { id: 3, name: 'Steady beam 41-60% intensity' },
  { id: 4, name: 'Steady beam 21-40% intensity' },
  { id: 5, name: 'Steady beam 0-20% intensity' },
  { id: 6, name: 'Slow flash mode' },
  { id: 7, name: 'Fast flash mode' },
  { id: 8, name: 'Randomly timed flash mode' },
  { id: 9, name: 'Auto' },
  { id: 59, name: 'Custom mode 1 (manufacturer-defined)' },
  { id: 60, name: 'Custom mode 2 (manufacturer-defined)' },
  { id: 61, name: 'Custom mode 3 (manufacturer-defined)' },
  { id: 62, name: 'Custom mode 4 (manufacturer-defined)' },
  { id: 63, name: 'Custom mode 5 (manufacturer-defined)' }
];

const bontragerIonProRtModes = [
  { id: 0, name: 'Off' },
  { id: 1, name: 'High' },
  { id: 2, name: 'Medium' },
  { id: 5, name: 'Low' },
  { id: 63, name: 'Day Flash' },
  { id: 62, name: 'Night Flash' }
];

export const controlMode = {id: -1, name: "Control mode"};

export const headlightList = [
  {
    id: 1,
    name: 'Bontrager ION PRO RT',
    modes: bontragerIonProRtModes,
    lightModes: [4587520, 196641], // 19703248369942561
    defaultLightPanel: {
      shortName: 'Ion Pro RT',
      buttonGroups: [
        [controlMode, bontragerIonProRtModes[0]],
        [bontragerIonProRtModes[1]],
        [bontragerIonProRtModes[2]],
        [bontragerIonProRtModes[3]],
        [bontragerIonProRtModes[4]],
        [bontragerIonProRtModes[5]]
      ]
    }
  },
  {
    id: 99,
    name: 'Unknown',
    modes: lightModes,
    lightModes: null,
    defaultLightPanel: null
  }
];

const bontragerFlareRtModes = [
  { id: 0, name: 'Off' },
  { id: 1, name: 'Day Steady' },
  { id: 5, name: 'Night Steady' },
  { id: 7, name: 'Day Flash' },
  { id: 8, name: 'All-Day Flash' },
  { id: 63, name: 'Night Flash' }
];

export const taillightList = [
  {
    id: 1,
    name: 'Bontrager Flare RT',
    modes: bontragerFlareRtModes,
    lightModes: [6291461, 1409482753], // 27021620648542209
    defaultLightPanel: {
      shortName: 'Flare RT',
      buttonGroups: [
        [controlMode, bontragerFlareRtModes[0]],
        [bontragerFlareRtModes[1]],
        [bontragerFlareRtModes[2]],
        [bontragerFlareRtModes[3]],
        [bontragerFlareRtModes[4]],
        [bontragerFlareRtModes[5]]
      ]
    }
  },
  {
    id: 99,
    name: 'Unknown',
    modes: lightModes,
    lightModes: null,
    defaultLightPanel: null
  }
];

export const getBatteryOperator = (operator) => {
  return operator === '<' ? '>'
    : operator === '>' ? '<'
    : operator;
};

export const getBatteryValue = (value) => {
  return 6 - value;
};