export const deviceList = [
  { id: 'B2819', name: 'D2 Charlie', polygons: true, touchScreen: false, settings: false },
  { id: 'B3197', name: 'D2 Delta', polygons: true, touchScreen: false, settings: false },
  { id: 'B3198', name: 'D2 Delta PX', polygons: true, touchScreen: false, settings: false },
  { id: 'B3196', name: 'D2 Delta S', polygons: true, touchScreen: false, settings: false },
  { id: 'B2859', name: 'Descent Mk1', polygons: true, touchScreen: false, settings: false },
  { id: 'B3258', name: 'Descent Mk2 / Descent Mk2i', polygons: true, touchScreen: false, settings: true },
  { id: 'B2713', name: 'Edge 1030', polygons: true, touchScreen: true, settings: false },
  { id: 'B3095', name: 'Edge 1030 / Bontrager', polygons: true, touchScreen: true, settings: false },
  { id: 'B3570', name: 'Edge 1030 Plus', polygons: true, touchScreen: true, settings: false },
  { id: 'B1836', name: 'Edge 1000 / Explore', polygons: true, touchScreen: true, settings: false },
  { id: 'B3011', name: 'Edge Explore', polygons: true, touchScreen: true, settings: false },
  { id: 'B3122', name: 'Edge 830', polygons: true, touchScreen: true, settings: false },
  { id: 'B2530', name: 'Edge 820 / Explore', polygons: true, touchScreen: true, settings: false },
  { id: 'B3121', name: 'Edge 530', polygons: true, touchScreen: false, settings: true },
  { id: 'B3112', name: 'Edge 520 Plus', polygons: true, touchScreen: false, settings: false },
  { id: 'B2067', name: 'Edge 520', polygons: false, touchScreen: false, settings: false },
  { id: 'B3558', name: 'Edge 130 Plus', polygons: false, touchScreen: false, settings: false },
  { id: 'B2909', name: 'Edge 130', polygons: false, touchScreen: false, settings: false },
  { id: 'B2697', name: 'fēnix 5 / quatix 5', polygons: false, touchScreen: false, settings: false },
  { id: 'B3110', name: 'fēnix 5 Plus', polygons: true, touchScreen: false, settings: false },
  //{ id: 'B2544', name: 'fēnix 5S', polygons: false, touchScreen: false, settings: false },
  { id: 'B2900', name: 'fēnix 5S Plus', polygons: true, touchScreen: false, settings: false },
  { id: 'B2604', name: 'fēnix 5X / tactix Charlie', polygons: true, touchScreen: false, settings: false },
  { id: 'B3111', name: 'fēnix 5X Plus', polygons: true, touchScreen: false, settings: false },
  { id: 'B3289', name: 'fēnix 6 / 6 Solar / 6 Dual Power"', polygons: false, touchScreen: false, settings: false },
  { id: 'B3290', name: 'fēnix 6 Pro / 6 Sapphire / 6 Pro Solar / 6 Pro Dual Power / quatix 6', polygons: true, touchScreen: false, settings: true },
  { id: 'B3287', name: 'fēnix 6S / 6S Solar / 6S Dual Power', polygons: false, touchScreen: false, settings: false },
  { id: 'B3288', name: 'fēnix 6S Pro / 6S Sapphire / 6S Pro Solar / 6S Pro Dual Power', polygons: true, touchScreen: false, settings: true },
  { id: 'B3291', name: 'fēnix 6X Pro / 6X Sapphire / 6X Pro Solar / tactix Delta Sapphire / Delta Solar / Delta Solar - Ballistics Edition / quatix 6X / 6X Solar / 6X Dual Power', polygons: true, touchScreen: false, settings: true },
  { id: 'B3076', name: 'Forerunner 245', polygons: false, touchScreen: false, settings: false },
  { id: 'B3077', name: 'Forerunner 245 Music', polygons: true, touchScreen: false, settings: true },
  { id: 'B2886', name: 'Forerunner 645', polygons: false, touchScreen: false, settings: false },
  { id: 'B2888', name: 'Forerunner 645 Music', polygons: true, touchScreen: false, settings: false },
  { id: 'B3589', name: 'Forerunner 745', polygons: true, touchScreen: false, settings: true },
  { id: 'B2691', name: 'Forerunner 935', polygons: false, touchScreen: false, settings: false },
  { id: 'B3113', name: 'Forerunner 945', polygons: true, touchScreen: false, settings: true },
  { id: 'B3501', name: 'First Avenger', polygons: false, touchScreen: false, settings: false },
  { id: 'B3499', name: 'Darth Vader', polygons: false, touchScreen: false, settings: false },
  { id: 'B3624', name: 'MARQ Adventurer', polygons: true, touchScreen: false, settings: true },
  { id: 'B3251', name: 'MARQ Athlete', polygons: true, touchScreen: false, settings: true },
  { id: 'B3247', name: 'MARQ Aviator', polygons: true, touchScreen: false, settings: true },
  { id: 'B3248', name: 'MARQ Captain / MARQ Captain: American Magic Edition', polygons: true, touchScreen: false, settings: true },
  { id: 'B3249', name: 'MARQ Commander', polygons: true, touchScreen: false, settings: true },
  { id: 'B3246', name: 'MARQ Driver', polygons: true, touchScreen: false, settings: true },
  { id: 'B3250', name: 'MARQ Expedition', polygons: true, touchScreen: false, settings: true },
  { id: 'B3739', name: 'MARQ Golfer', polygons: true, touchScreen: false, settings: true },
  { id: 'B2700', name: 'vívoactive 3', polygons: false, touchScreen: false, settings: false },
  { id: 'B3473', name: 'vívoactive 3 Mercedes-Benz Collection', polygons: false, touchScreen: false, settings: false },
  { id: 'B2988', name: 'vívoactive 3 Music', polygons: false, touchScreen: false, settings: false },
  { id: 'B3066', name: 'vívoactive 3 Music LTE', polygons: false, touchScreen: false, settings: false },
  { id: 'B3225', name: 'vívoactive 4', polygons: false, touchScreen: false, settings: false },
  //{ id: 'B3224', name: 'vívoactive 4S', polygons: false, touchScreen: false, settings: false }
];

let map = {};
deviceList.forEach(item => map[item.id] = item);

export const deviceMap = map;

export const isTouchScreen = (device) => {
  return device && deviceMap[device] && deviceMap[device].touchScreen;
};

export const hasSettings = (device) => {
  return device && deviceMap[device] && deviceMap[device].settings;
};

export const filterList = [
  { id: 'A', name: 'Acceleration' },
  { id: 'B', name: 'Light Battery' },
  { id: 'C', name: 'Speed' },
  { id: 'E', name: 'Timespan' },
  { id: 'F', name: 'Position' },
  { id: 'G', name: 'GPS accuracy' },
  { id: 'H', name: 'Timer state' }
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

export const timerStateList = [
  'NR', // Not recording
  'ST', // Recording stopped
  'PA', // Recording paused
  'RE'  // Recording
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

const garminVariaHl500 = [
  { id: 0, name: 'Off' },
  { id: 1, name: 'Overdrive' },
  { id: 2, name: 'High' },
  { id: 3, name: 'Medium' },
  { id: 4, name: 'Low' },
  { id: 7, name: 'Flash' }
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
    id: 2,
    name: 'Bontrager ION 200 RT',
    modes: bontragerIonProRtModes,
    lightModes: [4587520, 196641], // 19703248369942561
    defaultLightPanel: {
      shortName: 'Ion 200 RT',
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
    id: 3,
    name: 'Garmin Varia HL 500',
    modes: garminVariaHl500,
    lightModes: [0, 67121681], // 67121681
    defaultLightPanel: {
      shortName: 'Varia 500',
      buttonGroups: [
        [controlMode, garminVariaHl500[0]],
        [garminVariaHl500[1]],
        [garminVariaHl500[2]],
        [garminVariaHl500[3]],
        [garminVariaHl500[4]],
        [garminVariaHl500[5]]
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

const garminVariaRtl510 = [
  { id: 0, name: 'Off' },
  { id: 4, name: 'Soild' },
  { id: 7, name: 'Day Flash' },
  { id: 6, name: 'Night Flash' }
];

const garminVariaRtl515 = [
  { id: 0, name: 'Off' },
  { id: 4, name: 'Soild' },
  { id: 5, name: 'Peloton' },
  { id: 7, name: 'Day Flash' },
  { id: 6, name: 'Night Flash' }
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
    id: 2,
    name: 'Garmin Varia RTL510',
    modes: garminVariaRtl510,
    lightModes: [0, 73404416], // 73404416
    defaultLightPanel: {
      shortName: 'Varia 510',
      buttonGroups: [
        [controlMode, garminVariaRtl510[0]],
        [garminVariaRtl510[1]],
        [garminVariaRtl510[2]],
        [garminVariaRtl510[3]],
      ]
    }
  },
  {
    id: 3,
    name: 'Garmin Varia RTL515',
    modes: garminVariaRtl515,
    lightModes: [0, 73535488], // 73535488
    defaultLightPanel: {
      shortName: 'Varia 515',
      buttonGroups: [
        [controlMode, garminVariaRtl515[0]],
        [garminVariaRtl515[1]],
        [garminVariaRtl515[2]],
        [garminVariaRtl515[3]],
        [garminVariaRtl515[4]],
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