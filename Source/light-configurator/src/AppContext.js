import React from 'react';
import Configuration from './models/Configuration';

export const getContextValue = (theme, configuration, currentUser) => {
  return {
    theme: theme,
    configuration: configuration,
    currentUser: currentUser
  };
};

export const AppContext = React.createContext(getContextValue(null, new Configuration(), null));
