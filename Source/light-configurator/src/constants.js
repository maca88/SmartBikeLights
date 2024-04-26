export const filterList = [
  { id: 'A', name: 'Acceleration' },
  { id: 'B', name: 'Light Battery' },
  { id: 'C', name: 'Speed' },
  { id: 'E', name: 'Timespan' },
  { id: 'F', name: 'Position' },
  { id: 'G', name: 'GPS accuracy' },
  { id: 'H', name: 'Timer state' },
  { id: 'I', name: 'Bike radar' },
  { id: 'J', name: 'Start location' },
  { id: 'K', name: 'Profile name' },
  { id: 'L', name: 'Gradient' },
  { id: 'M', name: 'Solar intensity' },
  { id: 'N', name: 'Lights modes' },
];

let map = {};
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

export const controlModeList = [
  { id: 0, name: 'Smart' },
  { id: 1, name: 'Network' },
  { id: 2, name: 'Manual' }
];

map = {};
controlModeList.forEach(item => map[item.id] = item.name);

export const controlModeMap = map;

export const manualModeBehaviorList = [
  { id: 0, name: 'All light modes' },
  { id: 1, name: 'Specific light modes' }
]

export const unitList = [
  { id: 0, name: 'Metric (km/h)' },
  { id: 1, name: 'Statute (MPH)' },
];

export const speedUnitList = [
  { id: 0, name: 'km/h' },
  { id: 1, name: 'MPH' },
];

export const distanceUnitList = [
  { id: 0, name: 'meters' },
  { id: 1, name: 'feet' },
];

export const timeFormatList = [
  { id: 0, name: '24h' },
  { id: 1, name: '12h' },
];

export const operatorList = [
  { id: '=', name: 'Equal' },
  { id: '>', name: 'Greater Than' },
  { id: '≥', name: 'Greater Than or Equal' },
  { id: '<', name: 'Less Than' },
  { id: '≤', name: 'Less Than or Equal' }
];

export const setList = [
  { id: 0, name: 'Not set' },
  { id: 1, name: 'Is set' }
];

export const colors = [
  { id: 1, name: 'Black/White' },

  { id: 0xFFFFAA, name: 'Shalimar' },
  { id: 0xFFFF55, name: 'Laser Lemon' },
  { id: 0xFFFF00, name: 'Yellow' },
  { id: 0xFFAAFF, name: 'Lavender Rose' },
  { id: 0xFFAAAA, name: 'Sundown' },
  { id: 0xFFAA55, name: 'Texas Rose' },
  { id: 0xFFAA00, name: 'Orange' },

  { id: 0xFF55FF, name: 'Pink Flamingo' },
  { id: 0xFF55AA, name: 'Brilliant Rose' },
  { id: 0xFF5555, name: 'Sunset Orange' },
  { id: 0xFF5500, name: 'International Orange' },
  { id: 0xFF00FF, name: 'Magenta' },
  { id: 0xFF00AA, name: 'Hollywood Cerise' },
  { id: 0xFF0055, name: 'Razzmatazz' },
  { id: 0xFF0000, name: 'Red' },

  { id: 0xAAFFFF, name: 'Pale Turquoise' },
  { id: 0xAAFFAA, name: 'Mint Green' },
  { id: 0xAAFF55, name: 'Conifer' },
  { id: 0xAAFF00, name: 'Spring Bud' },
  { id: 0xAAAAFF, name: 'Perano' },
  { id: 0xAAAAAA, name: 'Dark Gray' },
  { id: 0xAAAA55, name: 'Olive Green' },
  { id: 0xAAAA00, name: 'Citrus' },

  { id: 0xAA55FF, name: 'Medium Purple' },
  { id: 0xAA55AA, name: 'Violet Blue' },
  { id: 0xAA5555, name: 'Apple Blossom' },
  { id: 0xAA5500, name: 'Rust' },
  { id: 0xAA00FF, name: 'Electric Purple' },
  { id: 0xAA00AA, name: 'Dark Magenta' },
  { id: 0xAA0055, name: 'Jazzberry Jam' },
  { id: 0xAA0000, name: 'Free Speech Red' },

  { id: 0x55FFFF, name: 'Baby Blue' },
  { id: 0x55FFAA, name: 'Medium Aquamarine' },
  { id: 0x55FF55, name: 'Screamin\' Green' },
  { id: 0x55FF00, name: 'Bright Green' },
  { id: 0x55AAFF, name: 'Cornflower Blue' },
  { id: 0x55AAAA, name: 'Cadet Blue' },
  { id: 0x55AA55, name: 'Fruit Salad' },
  { id: 0x55AA00, name: 'Kelly Green' },

  { id: 0x5555FF, name: 'Neon Blue' },
  { id: 0x5555AA, name: 'Rich Blue' },
  { id: 0x555555, name: 'Matterhorn' },
  { id: 0x555500, name: 'Verdun Green' },
  { id: 0x5500FF, name: 'Electric Indigo' },
  { id: 0x5500AA, name: 'Indigo' },
  { id: 0x550055, name: 'Tyrian Purple' },
  { id: 0x550000, name: 'Maroon' },

  { id: 0x00FFFF, name: 'Aqua' },
  { id: 0x00FFAA, name: 'Medium Spring Green' },
  { id: 0x00FF55, name: 'Malachite' },
  { id: 0x00FF00, name: 'Lime' },
  { id: 0x00AAFF, name: 'Deep Sky Blue' },
  { id: 0x00AAAA, name: 'Persian Green' },
  { id: 0x00AA55, name: 'Pigment Green' },
  { id: 0x00AA00, name: 'Islamic Green' },

  { id: 0x0055FF, name: 'Navy Blue' },
  { id: 0x0055AA, name: 'Cobalt' },
  { id: 0x005555, name: 'Mosque' },
  { id: 0x005500, name: 'Green' },
  { id: 0x0000FF, name: 'Blue' },
  { id: 0x0000AA, name: 'New Midnight Blue' },
  { id: 0x000055, name: 'Navy' }
];

export const logicalOperators = [
  { id: '!', name: 'And' },
  { id: '|', name: 'Or' },
];

export const buttonColors = colors.filter(o => o.id !== 1);

export const batteryStateList = [
  null,
  'Charging',
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
  'Not recording',
  'Recording stopped',
  'Recording paused',
  'Recording'
];

export const vehicleThreatList = [
  'None',
  'Medium',
  'High'
];

export const toneTypeList = [
  { id: 1, name: "Built-in" },
  { id: 2, name: "Custom" }
];

export const configurationList = [
  { id: 1, name: "Primary" },
  { id: 2, name: "Secondary" },
  { id: 3, name: "Tertiary" }
];

export const toneList = [
  { id: 0, name: "Key press" },
  { id: 1, name: "Activity start" },
  { id: 2, name: "Activity stop" },
  { id: 3, name: "Message available" },
  { id: 4, name: "Alert high note" },
  { id: 5, name: "Alert low note" },
  { id: 6, name: "Loud beep" },
  { id: 7, name: "Interval change" },
  { id: 8, name: "Alarm trigger" },
  { id: 9, name: "Activity reset" },
  { id: 10, name: "Lap completed" },
  { id: 11, name: "Annoying sound" },
  { id: 12, name: "Time threshold met" },
  { id: 13, name: "Distance threshold met" },
  { id: 14, name: "Activity failure" },
  { id: 15, name: "Activity success" },
  { id: 16, name: "Power on" },
  { id: 17, name: "Low battery" },
  { id: 18, name: "Error" },
];

export const buttonActionTypeList = [
  { id: 1, name: "Cycle light modes" },
  { id: 2, name: "Change light mode" },
  { id: 3, name: "Change configuration" },
  { id: 4, name: "Play tone" }
];

map = {};
buttonActionTypeList.forEach(item => map[item.id] = item.name);

export const buttonActionTypeMap = map;

export const buttonTriggerList = [
  { id: 1, name: "Single-click" },
  { id: 2, name: "Press and one second hold" },
  { id: 3, name: "Double-click" }
];

map = {};
buttonTriggerList.forEach(item => map[item.id] = item.name);

export const buttonTriggerMap = map;

const remoteControllerButtonList = [
  {
    id: 1,
    name: "Center button",
    triggers: [...buttonTriggerList]
  },
  {
    id: 2,
    name: "Top button",
    triggers: [...buttonTriggerList]
  },
  {
    id: 3,
    name: "Right button",
    triggers: [...buttonTriggerList]
  },
  {
    id: 4,
    name: "Bottom button",
    triggers: [...buttonTriggerList]
  },
  {
    id: 5,
    name: "Left button",
    triggers: [...buttonTriggerList]
  }
];

map = {};
remoteControllerButtonList.forEach(item => map[item.id] = item);

export const remoteControllerButtonMap = map;

export const remoteControllerList = [
  {
    id: 1,
    name: 'Bontrager TransmitR MicroRemote',
    shortName: 'MicroRemote',
    standaloneCenterButton: true,
    buttons: [
      remoteControllerButtonList[0]
    ]
  },
  {
    id: 2,
    name: 'Bontrager TransmitR Remote',
    standaloneCenterButton: false,
    shortName: 'Remote',
    buttons: [...remoteControllerButtonList]
  }
];

map = {};
remoteControllerList.forEach(item => map[item.id] = item);

export const remoteControllerMap = map;

const lightModes = [
  { id: 0, name: 'Off - 0' },
  { id: 1, name: 'Steady beam 81-100% intensity - 1' },
  { id: 2, name: 'Steady beam 61-80% intensity - 2' },
  { id: 3, name: 'Steady beam 41-60% intensity - 3' },
  { id: 4, name: 'Steady beam 21-40% intensity - 4' },
  { id: 5, name: 'Steady beam 0-20% intensity - 5' },
  { id: 6, name: 'Slow flash mode - 6' },
  { id: 7, name: 'Fast flash mode - 7' },
  { id: 8, name: 'Randomly timed flash mode - 8' },
  { id: 9, name: 'Auto - 9' },
  { id: 59, name: 'Custom mode 1 (manufacturer-defined) - 59' },
  { id: 60, name: 'Custom mode 2 (manufacturer-defined) - 60' },
  { id: 61, name: 'Custom mode 3 (manufacturer-defined) - 61' },
  { id: 62, name: 'Custom mode 4 (manufacturer-defined) - 62' },
  { id: 63, name: 'Custom mode 5 (manufacturer-defined) - 63' }
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

const garminVariaUt800 = [
  { id: 0, name: 'Off' },
  { id: 2, name: 'High' },
  { id: 3, name: 'Medium' },
  { id: 4, name: 'Low' },
  { id: 6, name: 'Night Flash' },
  { id: 7, name: 'Day Flash' }
];

const cycliqFly12Ce = [
  { id: 0, name: 'Off' },
  { id: 1, name: 'Constant High' },
  { id: 2, name: 'Constant Medium' },
  { id: 3, name: 'Constant Low' },
  { id: 6, name: 'Pulse High' },
  { id: 7, name: 'Flash High' },
  { id: 59, name: 'Pulse Medium' },
  { id: 60, name: 'Pulse Low' },
  { id: 61, name: 'Flash Medium' },
  { id: 62, name: 'Flash Low' }
];

const seeSenseBeam = [
  { id: 0, name: 'Off' },
  { id: 1, name: 'Steady 100%' },
  { id: 2, name: 'Steady 80%' },
  { id: 3, name: 'Steady 60%' },
  { id: 4, name: 'Steady 40%' },
  { id: 5, name: 'Steady 20%' },
  { id: 6, name: 'Night Flash' },
  { id: 7, name: 'Day Flash' }
];

const giantReconHl1800 = [
  { id: 0, name: 'Off' },
  { id: 2, name: 'High' },
  { id: 3, name: 'Medium' },
  { id: 4, name: 'Low' },
  { id: 8, name: 'Day Flash' }
];

const trekCommuterProRtModes = [
  { id: 0, name: 'Off' },
  { id: 1, name: 'High' },
  { id: 5, name: 'Low' },
  { id: 63, name: 'Day Flash' }
];

export const controlMode = {id: -1, name: "Control mode"};
export const currentConfiguration = {id: -2, name: "Current configuration"};

export const headlightList = [
  {
    id: 1,
    name: 'Bontrager ION PRO RT',
    modes: bontragerIonProRtModes,
    individualNetworkOnly: false,
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
    individualNetworkOnly: false,
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
    id: 9,
    name: 'Bontrager ION 800 RT',
    modes: bontragerIonProRtModes,
    individualNetworkOnly: false,
    lightModes: [4587520, 196641], // 19703248369942561
    defaultLightPanel: {
      shortName: 'Ion 800 RT',
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
    id: 5,
    name: 'Cycliq Fly12 CE',
    modes: cycliqFly12Ce,
    individualNetworkOnly: true,
    lightModes: [415312, 71303969], // 1783751528940321
    defaultLightPanel: {
      shortName: 'Fly12 CE',
      buttonGroups: [
        [controlMode, cycliqFly12Ce[0]],
        [cycliqFly12Ce[1]],
        [cycliqFly12Ce[2]],
        [cycliqFly12Ce[3]],
        [cycliqFly12Ce[5]],
        [cycliqFly12Ce[8]],
        [cycliqFly12Ce[9]],
        [cycliqFly12Ce[4]],
        [cycliqFly12Ce[6]],
        [cycliqFly12Ce[7]]
      ]
    }
  },
  {
    id: 3,
    name: 'Garmin Varia HL500',
    modes: garminVariaHl500,
    individualNetworkOnly: false,
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
    id: 4,
    name: 'Garmin Varia UT800',
    modes: garminVariaUt800,
    individualNetworkOnly: false,
    lightModes: [0, 73413136], // 73413136
    defaultLightPanel: {
      shortName: 'Varia 800',
      buttonGroups: [
        [controlMode, garminVariaUt800[0]],
        [garminVariaUt800[1]],
        [garminVariaUt800[2]],
        [garminVariaUt800[3]],
        [garminVariaUt800[4]],
        [garminVariaUt800[5]]
      ]
    }
  },
  {
    id: 7,
    name: 'Giant Recon HL1800',
    modes: giantReconHl1800,
    individualNetworkOnly: false,
    lightModes: [0, 1073754640], // 1073754640
    defaultLightPanel: {
      shortName: 'HL 1800',
      buttonGroups: [
        [controlMode, giantReconHl1800[0]],
        [giantReconHl1800[1]],
        [giantReconHl1800[2]],
        [giantReconHl1800[3]],
        [giantReconHl1800[4]]
      ]
    }
  },
  {
    id: 8,
    name: 'See.Sense ACE Front',
    modes: seeSenseBeam,
    individualNetworkOnly: true,
    lightModes: [0, 73605649], // 73605649
    defaultLightPanel: {
      shortName: 'ACE F',
      buttonGroups: [
        [controlMode, seeSenseBeam[0]],
        [seeSenseBeam[1]],
        [seeSenseBeam[2]],
        [seeSenseBeam[3]],
        [seeSenseBeam[4]],
        [seeSenseBeam[5]],
        [seeSenseBeam[6]],
        [seeSenseBeam[7]]
      ]
    }
  },
  {
    id: 6,
    name: 'See.Sense BEAM/BEAM+',
    modes: seeSenseBeam,
    individualNetworkOnly: true,
    lightModes: [0, 73605649], // 73605649
    defaultLightPanel: {
      shortName: 'BEAM',
      buttonGroups: [
        [controlMode, seeSenseBeam[0]],
        [seeSenseBeam[1]],
        [seeSenseBeam[2]],
        [seeSenseBeam[3]],
        [seeSenseBeam[4]],
        [seeSenseBeam[5]],
        [seeSenseBeam[6]],
        [seeSenseBeam[7]]
      ]
    }
  },
  {
    id: 10,
    name: 'Trek Commuter Pro RT',
    modes: trekCommuterProRtModes,
    individualNetworkOnly: false,
    lightModes: [4587520, 196641], // 19703248369942561
    defaultLightPanel: {
      shortName: 'Pro RT',
      buttonGroups: [
        [controlMode, trekCommuterProRtModes[0]],
        [trekCommuterProRtModes[1]],
        [trekCommuterProRtModes[2]],
        [trekCommuterProRtModes[3]]
      ]
    }
  },
  {
    id: 99,
    name: 'Unknown',
    modes: lightModes,
    individualNetworkOnly: false,
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

const garminVariaRtl500 = [
  { id: 0, name: 'Off' },
  { id: 1, name: 'Solid' },
  { id: 7, name: 'Flash' }
];

const garminVariaRtl501 = [
  { id: 0, name: 'Off' },
  { id: 1, name: 'Solid' }
];

const garminVariaRtl510 = [
  { id: 0, name: 'Off' },
  { id: 4, name: 'Solid' },
  { id: 7, name: 'Day Flash' },
  { id: 6, name: 'Night Flash' }
];

const garminVariaRtl511 = [
  { id: 0, name: 'Off' },
  { id: 4, name: 'Solid' }
];

const garminVariaRtl515 = [
  { id: 0, name: 'Off' },
  { id: 4, name: 'Solid' },
  { id: 5, name: 'Peloton' },
  { id: 7, name: 'Day Flash' },
  { id: 6, name: 'Night Flash' }
];

const garminVariaTl300 = [
  { id: 0, name: 'Off' },
  { id: 2, name: 'High' },
  { id: 3, name: 'Medium' },
  { id: 4, name: 'Low' },
  { id: 7, name: 'Day Flash' }
];

const mageneL508 = [
  { id: 0, name: 'Off' },
  { id: 4, name: 'Solid' },
  { id: 5, name: 'Peloton' },
  { id: 7, name: 'Flash' },
  { id: 6, name: 'Pulse' },
  { id: 63, name: 'Rotate' }
];

const seeSenseIcon2 = [
  { id: 0, name: 'Off' },
  { id: 1, name: 'Steady 100%' },
  { id: 2, name: 'Steady 80%' },
  { id: 3, name: 'Steady 60%' },
  { id: 4, name: 'Steady 40%' },
  { id: 5, name: 'Steady 20%' },
  { id: 6, name: 'Night Flash' },
  { id: 7, name: 'Day Flash' }
];

const cycliqFly6Ce = [
  { id: 0, name: 'Off' },
  { id: 1, name: 'Constant High' },
  { id: 2, name: 'Constant Medium' },
  { id: 3, name: 'Constant Low' },
  { id: 6, name: 'Pulse High' },
  { id: 7, name: 'Flash High' },
  { id: 59, name: 'Pulse Medium' },
  { id: 60, name: 'Pulse Low' },
  { id: 61, name: 'Flash Medium' },
  { id: 62, name: 'Flash Low' }
];

const brytonGardia300 = [
  { id: 0, name: 'Off' },
  { id: 2, name: 'High Solid' },
  { id: 4, name: 'Low Solid' },
  { id: 8, name: 'Group Ride' },
  { id: 6, name: 'Night Flash' },
  { id: 7, name: 'Day Flash' }
];

export const taillightList = [
  {
    id: 1,
    name: 'Bontrager Flare RT',
    modes: bontragerFlareRtModes,
    individualNetworkOnly: false,
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
    id: 14,
    name: 'Bryton Gardia R300',
    modes: brytonGardia300,
    individualNetworkOnly: false,
    lightModes: [0, 610283536], // 610283536
    defaultLightPanel: {
      shortName: 'Gardia 300',
      buttonGroups: [
        [controlMode, brytonGardia300[0]],
        [brytonGardia300[1]],
        [brytonGardia300[2]],
        [brytonGardia300[3]],
        [brytonGardia300[4]],
        [brytonGardia300[5]],
      ]
    }
  },
  {
    id: 6,
    name: 'Cycliq Fly6 CE',
    modes: cycliqFly6Ce,
    individualNetworkOnly: true,
    lightModes: [415312, 71303969], // 1783751528940321
    defaultLightPanel: {
      shortName: 'Fly6 CE',
      buttonGroups: [
        [controlMode, cycliqFly6Ce[0]],
        [cycliqFly6Ce[1]],
        [cycliqFly6Ce[2]],
        [cycliqFly6Ce[3]],
        [cycliqFly6Ce[5]],
        [cycliqFly6Ce[8]],
        [cycliqFly6Ce[9]],
        [cycliqFly6Ce[4]],
        [cycliqFly6Ce[6]],
        [cycliqFly6Ce[7]]
      ]
    }
  },
  {
    id: 12,
    name: 'Garmin Varia TL300',
    modes: garminVariaTl300,
    individualNetworkOnly: false,
    lightModes: [0, 67121680], // 67121680
    defaultLightPanel: {
      shortName: 'Varia 300',
      buttonGroups: [
        [controlMode, garminVariaTl300[0]],
        [garminVariaTl300[1]],
        [garminVariaTl300[2]],
        [garminVariaTl300[3]],
        [garminVariaTl300[4]],
      ]
    }
  },
  {
    id: 4,
    name: 'Garmin Varia RTL500',
    modes: garminVariaRtl500,
    individualNetworkOnly: false,
    lightModes: [0, 67108865], // 67108865
    defaultLightPanel: {
      shortName: 'Varia 500',
      buttonGroups: [
        [controlMode, garminVariaRtl500[0]],
        [garminVariaRtl500[1]],
        [garminVariaRtl500[2]]
      ]
    }
  },
  {
    id: 10,
    name: 'Garmin Varia RTL501',
    modes: garminVariaRtl501,
    individualNetworkOnly: false,
    lightModes: [0, 1], // 1
    defaultLightPanel: {
      shortName: 'Varia 501',
      buttonGroups: [
        [controlMode, garminVariaRtl501[0]],
        [garminVariaRtl501[1]]
      ]
    }
  },
  {
    id: 2,
    name: 'Garmin Varia RTL510',
    modes: garminVariaRtl510,
    individualNetworkOnly: false,
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
    id: 7,
    name: 'Garmin Varia RTL511',
    modes: garminVariaRtl511,
    individualNetworkOnly: false,
    lightModes: [0, 4096], // 4096
    defaultLightPanel: {
      shortName: 'Varia 511',
      buttonGroups: [
        [controlMode, garminVariaRtl511[0]],
        [garminVariaRtl511[1]]
      ]
    }
  },
  {
    id: 3,
    name: 'Garmin Varia RTL515',
    modes: garminVariaRtl515,
    individualNetworkOnly: false,
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
    id: 8,
    name: 'Garmin Varia RTL516',
    modes: garminVariaRtl511,
    individualNetworkOnly: false,
    lightModes: [0, 4096], // 4096
    defaultLightPanel: {
      shortName: 'Varia 516',
      buttonGroups: [
        [controlMode, garminVariaRtl511[0]],
        [garminVariaRtl511[1]]
      ]
    }
  },
  {
    id: 16,
    name: 'Garmin Varia eRTL615',
    modes: garminVariaRtl515,
    individualNetworkOnly: false,
    lightModes: [0, 73535488], // 73535488
    defaultLightPanel: {
      shortName: 'Varia 615',
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
    id: 11,
    name: 'Garmin Varia RCT715',
    modes: garminVariaRtl515,
    individualNetworkOnly: false,
    lightModes: [0, 73535488], // 73535488
    defaultLightPanel: {
      shortName: 'Varia 715',
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
    id: 15,
    name: 'Garmin Varia RCT716',
    modes: garminVariaRtl511,
    individualNetworkOnly: false,
    lightModes: [0, 4096], // 4096
    defaultLightPanel: {
      shortName: 'Varia 716',
      buttonGroups: [
        [controlMode, garminVariaRtl511[0]],
        [garminVariaRtl511[1]]
      ]
    }
  },
  {
    id: 13,
    name: 'Magene L508',
    modes: mageneL508,
    individualNetworkOnly: false,
    lightModes: [0, 73535488], // 73535488
    defaultLightPanel: {
      shortName: 'Magene 508',
      buttonGroups: [
        [controlMode, mageneL508[0]],
        [mageneL508[1]],
        [mageneL508[2]],
        [mageneL508[3]],
        [mageneL508[4]],
        [mageneL508[5]],
      ]
    }
  },
  {
    id: 9,
    name: 'See.Sense ACE Rear',
    modes: seeSenseIcon2,
    individualNetworkOnly: true,
    lightModes: [0, 73605649], // 73605649
    defaultLightPanel: {
      shortName: 'ACE R',
      buttonGroups: [
        [controlMode, seeSenseIcon2[0]],
        [seeSenseIcon2[1]],
        [seeSenseIcon2[2]],
        [seeSenseIcon2[3]],
        [seeSenseIcon2[4]],
        [seeSenseIcon2[5]],
        [seeSenseIcon2[6]],
        [seeSenseIcon2[7]]
      ]
    }
  },
  {
    id: 5,
    name: 'See.Sense ICON2',
    modes: seeSenseIcon2,
    individualNetworkOnly: true,
    lightModes: [0, 73605649], // 73605649
    defaultLightPanel: {
      shortName: 'ICON2',
      buttonGroups: [
        [controlMode, seeSenseIcon2[0]],
        [seeSenseIcon2[1]],
        [seeSenseIcon2[2]],
        [seeSenseIcon2[3]],
        [seeSenseIcon2[4]],
        [seeSenseIcon2[5]],
        [seeSenseIcon2[6]],
        [seeSenseIcon2[7]]
      ]
    }
  },
  {
    id: 99,
    name: 'Unknown',
    modes: lightModes,
    individualNetworkOnly: false,
    lightModes: null,
    defaultLightPanel: null
  }
];

export const getLight = (taillight, light) => {
  if (!light) {
    return null;
  }

  const lights = taillight ? taillightList : headlightList;
  return lights.find(l => l.id === light) || null;
};

export const getDeviceLights = (device, lightsList, useIndividualNetwork) => {
  return device.highMemory && useIndividualNetwork ? lightsList : lightsList.filter(o => !o.individualNetworkOnly);
};

export const getSeparatorColors = (device) => {
  var noSeparator = { id: -1, name: 'No separator' };
  return device.highMemory && device.bitsPerPixel > 1 ? [noSeparator, { id: 0, name: 'Activity color' }].concat(colors)
    : device.bitsPerPixel === 1 ? [noSeparator, { id: 0, name: 'Black/White' }]
    : [noSeparator].concat(colors.map(val => val.id !== 43775 /* Blue */ ? val : { id: 0, name: 'Blue' }));
};

export const getLightIconColors = (device) => {
  return device.bitsPerPixel === 1
    ? colors.filter(o => o.id === 1 /* Black/White */)
    : colors;
};

export const getButtonColors = () => {
  return [{ id: 0, name: 'Activity color' }].concat(colors.filter(o => o.id !== 1 /* Black/White */));
};

export const getButtonTextColors = () => {
  return [{ id: 0xFFFFFF, name: 'White' }].concat(colors.filter(o => o.id !== 1 /* Black/White */)).concat([{ id: 0x000000, name: 'Black' }]);
};

export const getBatteryOperator = (operator) => {
  return operator === '<' ? '>'
    : operator === '>' ? '<'
    : operator === '≤' ? '≥'
    : operator === '≥' ? '≤'
    : operator;
};

export const getBatteryValue = (value) => {
  return value == null ? null : 7 - value;
};

export const arrayMove = (array, oldIndex, newIndex) => {
  if (newIndex >= array.length) {
      let k = newIndex - array.length + 1;
      while (k--) {
        array.push(undefined);
      }
  }

  array.splice(newIndex, 0, array.splice(oldIndex, 1)[0]);
  return true;
};

export const arrayMoveUp = (array, element) => {
  const index = array.indexOf(element);
  const newIndex = index - 1;
  if (newIndex < 0) {
    return false;
  }

  return arrayMove(array, index, newIndex);
};

export const arrayMoveDown = (array, element) => {
  const index = array.indexOf(element);
  const newIndex = index + 1;
  if (index < 0 || newIndex >= array.length) {
    return false;
  }

  return arrayMove(array, index, newIndex);
};

export const getAppType = () => {
  return process.env.REACT_APP_TYPE;
}

export const isDataField = () => {
  return getAppType() === 'datafield';
}

export const areRemoteControllersSupported = (device) => {
  return isDataField() && device.highMemory && device.profileName;
}
