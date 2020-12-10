import React from 'react';
import Configuration from './models/Configuration';

export const getContextValue = (configuration) => {
  return {
    units: configuration.units,
    timeFormat: configuration.timeFormat
  };
};

export const AppContext = React.createContext(getContextValue(new Configuration()));