import React from 'react';
import Configuration from './models/Configuration';

export const getContextValue = (theme, configuration) => {
  return {
    theme: theme,
    configuration: configuration
  };
};

export const AppContext = React.createContext(getContextValue(null, new Configuration()));