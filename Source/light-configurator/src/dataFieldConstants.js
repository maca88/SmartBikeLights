export const deviceList = [
  { id: 'B2819', name: 'D2 Charlie', polygons: true, touchScreen: false, settings: false },
  { id: 'B3197', name: 'D2 Delta', polygons: true, touchScreen: false, settings: false },
  { id: 'B3198', name: 'D2 Delta PX', polygons: true, touchScreen: false, settings: false },
  { id: 'B3196', name: 'D2 Delta S', polygons: true, touchScreen: false, settings: false },
  { id: 'B3499', name: 'Darth Vader', polygons: false, touchScreen: false, settings: false },
  { id: 'B2859', name: 'Descent Mk1', polygons: true, touchScreen: false, settings: false },
  { id: 'B3258', name: 'Descent Mk2 / Descent Mk2i', polygons: true, touchScreen: false, settings: true },
  { id: 'B1836', name: 'Edge 1000 / Explore', polygons: true, touchScreen: true, settings: false },
  { id: 'B2713', name: 'Edge 1030', polygons: true, touchScreen: true, settings: false },
  { id: 'B3095', name: 'Edge 1030 / Bontrager', polygons: true, touchScreen: true, settings: false },
  { id: 'B3570', name: 'Edge 1030 Plus', polygons: true, touchScreen: true, settings: false },
  { id: 'B2909', name: 'Edge 130', polygons: false, touchScreen: false, settings: false },
  { id: 'B3558', name: 'Edge 130 Plus', polygons: false, touchScreen: false, settings: false },
  { id: 'B2067', name: 'Edge 520', polygons: false, touchScreen: false, settings: false },
  { id: 'B3112', name: 'Edge 520 Plus', polygons: true, touchScreen: false, settings: false },
  { id: 'B3121', name: 'Edge 530', polygons: true, touchScreen: false, settings: true },
  { id: 'B2530', name: 'Edge 820 / Explore', polygons: true, touchScreen: true, settings: false },
  { id: 'B3122', name: 'Edge 830', polygons: true, touchScreen: true, settings: false },
  { id: 'B3011', name: 'Edge Explore', polygons: true, touchScreen: true, settings: false },
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
  { id: 'B3501', name: 'First Avenger', polygons: false, touchScreen: false, settings: false },
  { id: 'B3076', name: 'Forerunner 245', polygons: false, touchScreen: false, settings: false },
  { id: 'B3077', name: 'Forerunner 245 Music', polygons: true, touchScreen: false, settings: true },
  { id: 'B2886', name: 'Forerunner 645', polygons: false, touchScreen: false, settings: false },
  { id: 'B2888', name: 'Forerunner 645 Music', polygons: true, touchScreen: false, settings: false },
  { id: 'B3589', name: 'Forerunner 745', polygons: true, touchScreen: false, settings: true },
  { id: 'B2691', name: 'Forerunner 935', polygons: false, touchScreen: false, settings: false },
  { id: 'B3113', name: 'Forerunner 945', polygons: true, touchScreen: false, settings: true },
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

export const getDevice = (device) => {
  return device && deviceMap[device];
};